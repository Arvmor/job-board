# ----------------
# Stage 1: deps
# ----------------
FROM node:20-alpine AS deps
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# ----------------
# Stage 2: builder
# ----------------
FROM node:20-alpine AS builder
WORKDIR /app

# Copy all source code
COPY . .

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Generate Prisma client with MUSL + native binaries
RUN npx prisma generate

# Build your Next.js app (make sure you have "output: 'standalone'" in next.config.js)
RUN npm run build

# ----------------
# Stage 3: runner
# ----------------
FROM node:20-alpine AS runner
WORKDIR /app

# Copy the standalone build output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./

# Expose the port and start
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
    