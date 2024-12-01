FROM xiaoyaliu/glue:python

COPY --chmod=755 . /

RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache -r /115cookie/requirements.txt && \
    pip install --no-cache -r /aliyuntvtoken/requirements.txt && \
    pip install --no-cache -r /aliyuntoken/requirements.txt && \
    pip install --no-cache -r /aliyunopentoken/requirements.txt && \
    pip install --no-cache -r /quark_cookie/requirements.txt && \
    pip install --no-cache -r /uc_cookie/requirements.txt && \
    pip install --no-cache -r /get_folder_id/requirements.txt
