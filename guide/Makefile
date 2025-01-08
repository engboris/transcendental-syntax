all:
	deploy

deploy:
	git pull
	mdbook build
	sudo rsync -aux book/. /var/www/tsguide.refl.fr/.
