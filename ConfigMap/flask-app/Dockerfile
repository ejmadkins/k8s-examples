FROM python:3.7-alpine
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt

ENV TITLE Pics
ENV NAME Ed
ENV ENV Prod
ENV PIC https://cbsnews1.cbsistatic.com/hub/i/2012/09/03/23633c73-a645-11e2-a3f0-029118418759/greatwhiteshark.jpg

ENTRYPOINT [ "python" ]
CMD [ "app.py" ]