# --------------------------
# 1. Dependencies Stage
# --------------------------
FROM node:20-alpine AS deps

# Install OpenSSL 1.1 compat so Prisma can function
RUN apk add --no-cache compat-openssl1.1

WORKDIR /app
COPY package*.json ./
RUN npm install

# --------------------------
# 2. Build Stage
# --------------------------
FROM node:20-alpine AS builder

# Install OpenSSL 1.1 compat for Prisma during build
RUN apk add --no-cache compat-openssl1.1

WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules

# Generate Prisma client and build the Next.js app
RUN npx prisma generate
RUN npm run build

# --------------------------
# 3. Runtime Stage
# --------------------------
FROM node:20-alpine AS runner

# Install OpenSSL 1.1 compat for Prisma in production
RUN apk add --no-cache compat-openssl1.1

WORKDIR /app

# Copy the output from the build stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]
    