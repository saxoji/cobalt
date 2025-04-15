
FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app
RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app
COPY --from=build --chown=node:node /prod/api /app

# 가짜 Git 리포지토리 구조 생성
RUN mkdir -p .git/refs/heads .git/objects/00
RUN echo "ref: refs/heads/main" > .git/HEAD
RUN echo "0000000000000000000000000000000000000000" > .git/refs/heads/main
RUN touch .git/objects/00/00000000000000000000000000000000000000
RUN echo "[remote \"origin\"]\n\turl = https://github.com/imputnet/cobalt.git" > .git/config
RUN echo "v10.9.1" > .git/VERSION

USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
