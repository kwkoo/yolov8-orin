FROM nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3

EXPOSE 8080

ENV \
  CAMERA="/dev/video0" \
  CONFIDENCE="0.5"

RUN \
  rm -f /usr/local/lib/python3.8/dist-packages/cv2 \
  && \
  mv /usr/lib/python3.8/dist-packages/* /usr/local/lib/python3.8/dist-packages/ \
  && \
  rm -rf /usr/lib/python3.8/dist-packages \
  && \
  ln -s /usr/lib/local/lib/python3.8/dist-packages /usr/lib/python3.8/dist-packages \
  && \
  pip3 uninstall -y opencv-python \
  && \
  rm -rf /usr/local/lib/python3.8/dist-packages/cv2 \
  && \
  pip3 install -U numpy \
  && \
  pip3 install opencv-python==4.8.1.78 \
  && \
  git clone https://github.com/ultralytics/ultralytics.git /ultralytics \
  && \
  cd /ultralytics \
  && \
  pip3 install .

COPY app/ /app
WORKDIR /app
RUN \
  apt update -y \
  && \
  apt install -y curl \
  && \
  pip3 install flask \
  && \
  curl -Lo /app/yolov8n.pt https://github.com/ultralytics/assets/releases/download/v8.1.0/yolov8n.pt

CMD ["python3", "./app.py"]
