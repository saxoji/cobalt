FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app
RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk git
# .git이 존재하면 버전 정보 생성
RUN if [ -d .git ]; then \
        git rev-parse HEAD > /app/version.txt && \
        git log -1 --pretty=%B >> /app/version.txt; \
    else \
        echo "Git 정보가 없습니다" > /app/version.txt; \
    fi
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api
# 버전 파일도 프로덕션 디렉토리로 복사
RUN cp /app/version.txt /prod/api/version.txt

FROM base AS api
WORKDIR /app
COPY --from=build --chown=node:node /prod/api /app
# .git 디렉토리를 복사할 필요 없음

USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
