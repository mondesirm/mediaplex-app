# Utilisez une image de base avec Flutter préinstallé
FROM fischerscode/flutter

# Définissez le répertoire de travail dans lequel vous souhaitez copier votre application Flutter
WORKDIR /app

# Copiez le contenu de votre application Flutter (y compris le fichier pubspec.yaml) dans le conteneur
COPY . .

# Exécutez la commande flutter pub get pour installer les dépendances
RUN flutter pub get

# Build l'application pour le web
RUN flutter build web

# Exposez le port 80 (ou tout autre port que votre application utilise)
EXPOSE 80


