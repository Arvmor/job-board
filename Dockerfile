FROM node:20-alpine3.20 AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM node:20-alpine3.20 AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npx prisma generate
RUN npm run db:seed
RUN npm run build

FROM node:20-alpine3.20 AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

EXPOSE 3000
ENV PORT 3000
CMD ["node", "server.js"]