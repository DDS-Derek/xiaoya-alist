#!/bin/bash

exec dumb-init java -jar -Dfile.encoding=UTF-8 -Xmx64m /xiaoya_proxy.jar com.ddsrem.xiaoya_proxy.XiaoyaProxyRun
