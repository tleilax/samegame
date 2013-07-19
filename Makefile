build: css js

css:
	recess --compile ./assets/styles.less > ./assets/styles.css
	recess --compress ./assets/styles.less > ./assets/styles.min.css

js:
	coffee --compile --print --bare ./assets/application.coffee > ./assets/application.js
	uglifyjs ./assets/application.js --mangle --compress > ./assets/application.min.js

update:
	composer update
