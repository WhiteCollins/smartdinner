# Imagen base
FROM node:20-alpine

WORKDIR /app

# Instalar dependencias
COPY package*.json ./
RUN npm ci

# Copiar código
COPY . .

# Variables de entorno por defecto (se pueden sobrescribir con env_file)
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Ajusta este comando si tu package.json usa otro script (por ejemplo: start:dev)
CMD ["npm", "run", "start"]