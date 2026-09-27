FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copiar manifiestos de npm
COPY package.json package-lock.json* ./

# Instalar dependencias exactas con npm ci
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Compilar Next.js
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOST=0.0.0.0
ENV PORT=3000

# Copiar todo el entorno necesario para el custom server (server/index.js)
COPY --from=builder /app ./

EXPOSE 3000

# Claw3D arranca con npm run start para montar el gateway proxy y el servidor
CMD ["npm", "run", "start"]
