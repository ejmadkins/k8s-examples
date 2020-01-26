from flask import Flask
import os

title = os.environ.get('TITLE')
name = os.environ.get('NAME')

app = Flask(__name__)
app.config.from_pyfile('/config/config.cfg')

@app.route('/')
def hello():
    return """
<!DOCTYPE html>
<head>
   <title>{0}</title>
</head>
<body>  
    <h1>Hey there {1}, we're running in {2}</h1>
    <p>here's a fun pic!</p>
    <img src="{3}" alt="cool pic isn't it!">
</body>
""".format(title, name, app.config['ENV'], app.config['PIC'])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')