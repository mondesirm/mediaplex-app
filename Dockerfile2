# Utilisez une image de base Apache officielle
FROM httpd:2.4

# Copiez le contenu de votre application Flutter Web dans le répertoire "/usr/local/apache2/htdocs/"
COPY ./build/web/ /usr/local/apache2/htdocs/

# Exposez le port 80 (HTTP)
EXPOSE 80

# Facultatif : si vous souhaitez personnaliser la configuration d'Apache, vous pouvez copier vos fichiers de configuration personnalisés ici.
# COPY ./mon_apache.conf /usr/local/apache2/conf/httpd.conf
