FROM public.ecr.aws/docker/library/node:22.22.1-slim
RUN npm install -g npm@11 --loglevel=error


# Instalar curl
RUN apt-get update \
  && apt-get install -y curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copia dependências da API
COPY package*.json ./
RUN npm install --loglevel=error

# Copia dependências do client
COPY client/package*.json ./client/
RUN cd client && npm install --legacy-peer-deps --loglevel=error

# Copia todo projeto
COPY . .

# Build do frontend
WORKDIR /usr/src/app/client
RUN VITE_API_URL=http://bia-alb-1945867359.us-east-1.elb.amazonaws.com npm run build

# Remove dev dependencies do client
RUN npm prune --production && rm -rf node_modules/.cache

WORKDIR /usr/src/app

EXPOSE 8080

CMD ["npm", "start"]
