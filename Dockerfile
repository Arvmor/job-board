# --------------------------
# 1. Dependencies Stage
# --------------------------
FROM node:20-alpine AS deps

# Install OpenSSL 1.1 compatibility for Prisma
RUN apk add --no-cache openssl1.1-compat

WORKDIR /app
COPY package*.json ./
RUN npm install

# --------------------------
# 2. Build Stage
# --------------------------
FROM node:20-alpine AS builder

# Install OpenSSL 1.1 compatibility again if you run Prisma here
RUN apk add --no-cache openssl1.1-compat

WORKDIR /app
COPY . .
# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Run Prisma commands here (generate, migrate) if needed
RUN npx prisma generate

# Build your Next.js (or other) app
RUN npm run build

# --------------------------
# 3. Runner Stage
# --------------------------
FROM node:20-alpine AS runner

# Install OpenSSL 1.1 compatibility so the runtime can execute Prisma queries
RUN apk add --no-cache openssl1.1-compat

WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

EXPOSE 3000
ENV PORT 3000
CMD ["node", "server.js"]
