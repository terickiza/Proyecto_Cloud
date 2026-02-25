#Imagen base ligera
FROM python:3.9-slim

#Establecer el directorio de trabajo
WORKDIR /app

#Copiar los archivos necesarios
COPY requirements.txt .
COPY app.py .

#Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt      

#Exponer el puerto de la aplicación
EXPOSE 5000 

#Comando para ejecutar la aplicación
CMD ["python", "app.py"]