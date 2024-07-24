#!/bin/bash

exec dumb-init java -Xmx64m -cp /xiaoya_proxy.jar com.ddsrem.xiaoya_proxy.XiaoyaProxyRun
