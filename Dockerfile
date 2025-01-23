FROM node:20-alpine3.17 AS deps
WORKDIR /app
RUN apk add --no-cache compat-openssl1.1

COPY package*.json ./
RUN npm i

FROM node:20-alpine3.17 AS builder
WORKDIR /app
RUN apk add --no-cache compat-openssl1.1

COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npx prisma generate
RUN npm run build

FROM node:20-alpine3.17 AS runner
WORKDIR /app
RUN apk add --no-cache compat-openssl1.1

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]
    