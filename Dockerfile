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

# Git 정보 대신 환경 변수 설정
ENV GIT_COMMIT_HASH="unknown"
ENV GIT_COMMIT_MESSAGE="Deployed without git info"
ENV GIT_COMMIT_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
