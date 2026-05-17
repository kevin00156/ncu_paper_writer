# docker/ — CI build images

把 PaperForge build pipeline 用的「重」依賴（TeX Live、Chromium、Noto CJK 字體）打包成預建 image，
讓 `.github/workflows/build.yml` 不必每次 CI 都重跑 `apt install`。

## 兩個 image

| Image | Dockerfile | 內含 | 用途 |
|---|---|---|---|
| `ghcr.io/<owner>/paperforge-paper` | [paper.Dockerfile](paper.Dockerfile) | Pandoc + TeX Live (xetex/lang-cjk/...) + biber + lmodern + Noto CJK | 編譯論文／報告 PDF |
| `ghcr.io/<owner>/paperforge-slides` | [slides.Dockerfile](slides.Dockerfile) | Node 20 + marp-cli + Chrome for Testing + Noto CJK + chromium runtime libs | 編譯 Marp 簡報 PDF/HTML |

`<owner>` = GitHub repo 擁有者，全小寫。本 repo 為 `ghcr.io/kevin00156/paperforge-paper` 等。

## 兩支 workflow，分工

| Workflow | 觸發 | 做什麼 | tag |
|---|---|---|---|
| [`docker-images.yml`](../.github/workflows/docker-images.yml) | push 改到 `docker/**`、手動 | 推 `:latest`（main 分支）/ `:<branch-slug>` / `:sha-<7chars>` | 給外部 / release 用 |
| [`build.yml`](../.github/workflows/build.yml) 內的 `prepare-*-image` job | 每次 CI 跑 | 推 `:ci-<run_id>`，後續 build job 用這個 tag | 給 CI 自己用 |

兩者都用 GitHub Actions cache (`type=gha`) — Dockerfile 沒變時 build 幾乎瞬間完成。

### 為何 build.yml 自己 build image，而不是只用 `:latest`?

避免「同一個 PR 同時改 Dockerfile + 範例」時的 race：
- 若 build.yml 直接 pull `:latest`，PR 上跑時 image 是上一版本，測不到本 PR 的 Dockerfile 改動。
- 若 build.yml 改成 `needs: docker-images`，又會跨 workflow 依賴、複雜。

所以 build.yml 自包含 — prepare-image job 走 GHA cache，重複跑成本很低；docker-images.yml 純粹負責把 `:latest` 推給外部使用者。

## 第一次設定（new repo / fork）

1. **第一次 push 到任何分支且改到 `docker/**`**：`docker-images.yml` 會自動跑並把 image 推到 GHCR。
2. **檢查 GHCR package visibility**：
   - **Public repo**：image 預設會繼承 repo 設定（public），通常不用動。
   - **Private repo / fork**：image 預設是 private，fork 拉不到。需到 `https://github.com/<owner>/<repo>/pkgs/container/paperforge-paper/settings`，Danger Zone → Change package visibility → Public。`paperforge-slides` 同。
3. **確認 build.yml 跑得起來**：在 Actions 頁手動觸發 `Build Examples` workflow。

## 本機測試 Dockerfile

```bash
# 在 repo root 執行
docker build -f docker/paper.Dockerfile -t paperforge-paper:local docker
docker run --rm -it -v "$PWD:/workspace" paperforge-paper:local \
    bash -c "./scripts/build.sh examples/minimal/paper.md --verbose"

docker build -f docker/slides.Dockerfile -t paperforge-slides:local docker
docker run --rm -it -v "$PWD:/workspace" paperforge-slides:local \
    bash -c "./scripts/build-slides.sh examples/slides-minimal/slides.md --pdf"
```

## 加新依賴時

1. 改對應 `.Dockerfile`，commit 上 PR。
2. PR 上的 `build.yml` 會自動 build 包含新依賴的 image（GHA cache miss → 全量重建）並用於測試。
3. PR 合進 main 後，`docker-images.yml` 會更新 `:latest`，下次別人 fork / 用 `:latest` 的工具就會抓到新版。

## 為何不用 official `marpteam/marp-cli` image？

官方 image 不含 chromium runtime libs（要 sidecar），且不含 CJK 字體。自製成本不高。

## 為何 paper image 用 ubuntu:24.04、slides image 用 debian:bookworm？

- paper：TeX Live 套件名稱與 Ubuntu CI runner 一致，最大化跟現有 `build.sh` 行為的相容性。
- slides：`node:20-bookworm-slim` 已含 npm + node 而且 chromium runtime lib（`libasound2` 等）在 bookworm 沒被改名（24.04 改成 `libasound2t64` 是坑），直接用較穩。
