#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2086
# shellcheck source=/dev/null
PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/homebrew/bin
export PATH
#
# ——————————————————————————————————————————————————————————————————————————————————
# __   ___                                    _ _     _
# \ \ / (_)                             /\   | (_)   | |
#  \ V / _  __ _  ___  _   _  __ _     /  \  | |_ ___| |_
#   > < | |/ _` |/ _ \| | | |/ _` |   / /\ \ | | / __| __|
#  / . \| | (_| | (_) | |_| | (_| |  / ____ \| | \__ \ |_
# /_/ \_\_|\__,_|\___/ \__, |\__,_| /_/    \_\_|_|___/\__|
#                       __/ |
#                      |___/
#
# Copyright (c) 2024 DDSRem <https://blog.ddsrem.com>
#
# This is free software, licensed under the GNU General Public License v3.0.
#
# ——————————————————————————————————————————————————————————————————————————————————
#
DATE_VERSION="v1.8.0-2024_11_23_17_53"
#
# ——————————————————————————————————————————————————————————————————————————————————
amilys_embyserver_latest_version=4.8.10.0
emby_embyserver_latest_version=4.8.10.0
amilys_embyserver_beta_version=4.9.0.32
emby_embyserver_beta_version=4.9.0.32
# ——————————————————————————————————————————————————————————————————————————————————

Sky_Blue="\e[36m"
Blue="\033[34m"
Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
    echo -e "${INFO} ${1}"
}
function ERROR() {
    echo -e "${ERROR} ${1}"
}
function WARN() {
    echo -e "${WARN} ${1}"
}

# shellcheck disable=SC2034
mirrors=(
    "docker.io"
    "registry-docker-hub-latest-9vqc.onrender.com"
    "docker.fxxk.dedyn.io"
    "dockerproxy.com"
    "hub.uuuadc.top"
    "docker.jsdelivr.fyi"
    "docker.registry.cyou"
    "dockerhub.anzu.vip"
    "docker.luyao.dynv6.net"
    "freeno.xyz"
    "docker.1panel.live"
    "dockerpull.com"
    "docker.anyhub.us.kg"
    "dockerhub.icu"
    "docker.nastool.de"
)

pikpakshare_list_base64="6auY5riF55S15b2xL+WQiOmbhjEgICAgICAgICAgVk5SbE5MQVJMbXl5MVZtMjVDSlBwYzBYbzEgICAgVk5SbE1Xd2lMbXl5MVZtMjVDSlBwUnpNbzEK6auY5riF55S15b2xL+WQiOmbhjIgICAgICAgICAgVk5SbFZ3UVlRZ3F2Mzk1a3hHQmhQbURvbzEgICAgVk5SbE9mSjBVVTluakpPUmh1cnpic2RwbzEK6auY5riF55S15b2xL+WQiOmbhjMgICAgICAgICAgVk5SbTN5WnRCR3l3S2ExMTh2enZnQWc2bzEgICAgVk5SbGtETExVVTluakpPUmh1cnpoNEZRbzEK6auY5riF55S15b2xL+WQiOmbhjQgICAgICAgICAgVk5SbVdPbVFCR3l3S2ExMTh2enZsUmlabzEgICAgVk5SbThGcGc3YVdOM0hXSkdWR3A4YXhUbzEgCumrmOa4heeUteW9sS/lkIjpm4Y1ICAgICAgICAgIFZOUm1vRm1vcm9SUk9oRWtob184a1lfMW8xICAgIFZOUm1aTVAxUWdxdjM5NWt4R0JoZC15UW8xCumrmOa4heeUteW9sS/lkIjpm4Y2ICAgICAgICAgIFZOUm42SHFpQkd5d0thMTE4dnp2dXFGcW8xICAgIFZOUm1yZlRBQkd5d0thMTE4dnp2cWJjdG8xCumrmOa4heeUteW9sS/lkIjpm4Y3ICAgICAgICAgIFZOUm5KQVNVcm9SUk9oRWtob184dHBHZm8xICAgIFZOUm5BenZuQkd5d0thMTE4dnp2d0cxV28xCumrmOa4heeUteW9sS/lkIjpm4Y4ICAgICAgICAgIFZOUmxnMHBTN2FXTjNIV0pHVkdwMnBaVG8xICAgIFZOUmxadzRqVVU5bmpKT1JodXJ6ZVYzRW8xCumrmOa4heeUteW9sS/lkIjpm4Y5ICAgICAgICAgIFZOUm5RYk1ON2FXTjNIV0pHVkdwU2t4Rm8xICAgIFZOUm5OYTRweU0yTlFZbEtvNzhRNzBGX28xCumrmOa4heeUteW9sS/lkIjpm4YxMCAgICAgICAgIFZOUm5hZ0JVQ2ZPaXBCRm9XQ1g4RUdTZG8xICAgIFZOUm5ZN3RvZzNiX29yd2tvSDNheGZQQm8xCumrmOa4heeUteW9sS/lkIjpm4YxMSAgICAgICAgIFZOUlIxY2MwTG15eUdEZTIxQW9LNlVsaG8xICAgIFZOUlF6Um5iTG15eUdEZTIxQW9LNWQtOW8xCumrmOa4heWJp+mbhkEv5ZCI6ZuGMSAgICAgICAgIFZOUlQ4V3I4Qkd5dzFrdDFIa2lqS1I0UW8xICAgIFZOUWY2Wm1XRTNwVldHcHVGcmlHcXlQem8xCumrmOa4heWJp+mbhkEv5ZCI6ZuGMiAgICAgICAgIFZOUlQ4V3I4Qkd5dzFrdDFIa2lqS1I0UW8xICAgIFZOUWY2WjQ1b2hnZVpPMXNtb2RLZ3hscW8xCumrmOa4heWJp+mbhkEv5ZCI6ZuGMyAgICAgICAgIFZOUlQ4elpYZzNiX1ZZc24wYkN3bFZoNW8xICAgIFZOUWY3SHY4RTNwVldHcHVGcmlHcjdubm8xCumrmOa4heWJp+mbhkEv5ZCI6ZuGNCAgICAgICAgIFZOUlQ4elpYZzNiX1ZZc24wYkN3bFZoNW8xICAgIFZOUWY3QTBZZUlfNW1ObmlwN0IySXZZcG8xICAK6auY5riF5Ymn6ZuGQS/lkIjpm4Y1ICAgICAgICAgVk5SVDllWWVCR3l3MWt0MUhraWpLbUxfbzEgICAgVk5RZkFuY0lIVl9xMHZlNl9fUzlId1JZbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4Y2ICAgICAgICAgVk5SVDllWWVCR3l3MWt0MUhraWpLbUxfbzEgICAgVk5RZkF3ZE5FM3BWV0dwdUZyaUdzTDVQbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4Y3ICAgICAgICAgVk5SVDllWWVCR3l3MWt0MUhraWpLbUxfbzEgICAgVk5RZkI4QVk5LXNGM3FXY09PSkQ5T0pGbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4Y4ICAgICAgICAgVk5SVEEySE9nM2JfVllzbjBiQ3dsaEt5bzEgICAgVk5RZkJyVXJvaGdldndRNlphVlpFMV8wbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4Y5ICAgICAgICAgVk5SVEEySE9nM2JfVllzbjBiQ3dsaEt5bzEgICAgVk5RZkM1U0dFM3BWV0dwdUZyaUdzZ0FjbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxMCAgICAgICAgVk5SVEEySE9nM2JfVllzbjBiQ3dsaEt5bzEgICAgVk5RZkNBQng5LXNGM3FXY09PSkQ5Z2hybzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxMSAgICAgICAgVk5SVEFNTnZCR3l3MWt0MUhraWpMLW4wbzEgICAgVk5RZkNfRVpPX2UwNXVSSE9WelFEdTgzbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxMiAgICAgICAgVk5SVEFNTnZCR3l3MWt0MUhraWpMLW4wbzEgICAgVk5RZkNxMklUdTVRUzJwdU1PLWgzaUVFbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxMyAgICAgICAgVk5SVEFNTnZCR3l3MWt0MUhraWpMLW4wbzEgICAgVk5RZkN6RjZBZVpqUjMteGJGLUlQQTEybzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxNCAgICAgICAgVk5SVEFoT1pMbXl5WDd5aUNiNnQxalR1bzEgICAgVk5RZkRVb21IVl9xSm9kQjJHQkw4OEdmbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxNSAgICAgICAgVk5SVEFoT1pMbXl5WDd5aUNiNnQxalR1bzEgICAgVk5RZkRjeXJPX2UwNXVSSE9WelFFSm53bzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxNiAgICAgICAgVk5SVEFoT1pMbXl5WDd5aUNiNnQxalR1bzEgICAgVk5RZkVJSzlPX2UwZVZfRl9UTVhOd0E5bzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxNyAgICAgICAgVk5SVEFoT1pMbXl5WDd5aUNiNnQxalR1bzEgICAgVk5RZkVqamFIVl9xSm9kQjJHQkw4ZGVDbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxOCAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkducmlUdTVRY1FTeFVRV25VVlZXbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YxOSAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkd0RDZlSV81Ynl3bWlJMC1Sb3FNbzEK6auY5riF5Ymn6ZuGQS/lkIjpm4YyMCAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkgxZnMxb2dXRmFaaU96ZjRTcV9tbzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyMSAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkgyeWhBZVpqYlVMbkExc2ZmWUFYbzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyMiAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkhEQjVlSV81Ynl3bWlJMC1SdHFkbzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyMyAgICAgICAgVk5SVEJDS1BMbXl5WDd5aUNiNnQxcUVLbzEgICAgVk5RZkhYZklFM3BWeVctaDFpZWloZmlGbzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyNCAgICAgICAgVk5SVENLNExnM2JfVllzbjBiQ3dtZVdYbzEgICAgVk5RZklUcDZPX2Uwc0U5UldwSHZlRTg0bzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyNSAgICAgICAgVk5SVENLNExnM2JfVllzbjBiQ3dtZVdYbzEgICAgVk5RZklYVmpIVl9xM18wTDZ1cGFXTFN0bzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyNiAgICAgICAgVk5SVENLNExnM2JfVllzbjBiQ3dtZVdYbzEgICAgVk5RZklfd1JUdTVRaFF0UDh0YTBKRlVubzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyNyAgICAgICAgVk5SVENLNExnM2JfVllzbjBiQ3dtZVdYbzEgICAgVk5RZkljcnNUdTVRaFF0UDh0YTBKR1g0bzEK6auY5riF5Ymn6ZuGQi/lkIjpm4YyOCAgICAgICAgVk5SVENLNExnM2JfVllzbjBiQ3dtZVdYbzEgICAgVk5RZklmNE1vaGdlQlcteVVodHlNTmZxbzEgCumrmOa4heWJp+mbhkIv5ZCI6ZuGMjkgICAgICAgIFZOUlRDSzRMZzNiX1ZZc24wYkN3bWVXWG8xICAgIFZOUWk2SkIxT19lMGNQd0MwMnJCbERadm8xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzAgICAgICAgIFZOUlRDbWJuQ2ZPaTFabDJGdDI1U2p3OG8xICAgIFZOUWlBaElfRTNwVlVJQlc1NkJlQV9qQ28xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzEgICAgICAgIFZOUlRDbWJuQ2ZPaTFabDJGdDI1U2p3OG8xICAgIFZOUWlELXduRTNwVlVJQlc1NkJlQXpaNm8xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzIgICAgICAgIFZOUlREMmNleU0yTlFZbEtvNzhNRXpZMG8xICAgIFZOUWlGbTh0SFZfcXEyeTBGOHBnTG8wQ28xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzMgICAgICAgIFZOUlREMmNleU0yTlFZbEtvNzhNRXpZMG8xICAgIFZOUWlHSkMyb2hnZU55Rjctb0xyOENfdG8xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzQgICAgICAgIFZOUlRESF9LQkd5dzFrdDFIa2lqTUhHNW8xICAgIFZOUWlJWmV4T19lMGNQd0MwMnJCbm5zTG8xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzUgICAgICAgIFZOUlREaDlmUWdxdl82bFNZNVo3NVo1WW8xICAgIFZOUWlKa0dwRTNwVlVJQlc1NkJlQ0ZOd28xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzYgICAgICAgIFZOUlREaDlmUWdxdl82bFNZNVo3NVo1WW8xICAgIFZOUWlLamVqb2hnZU55Rjctb0xyOTN2b28xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzcgICAgICAgIFZOUlREeXNoUWdxdl82bFNZNVo3NWE0Mm8xICAgIFZOUWlOUDJxRTNwVlVJQlc1NkJlRDB0SG8xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzggICAgICAgIFZOUlREeXNoUWdxdl82bFNZNVo3NWE0Mm8xICAgIFZOUWlNS1lNT19lMGNQd0MwMnJCb1lOY28xCumrmOa4heWJp+mbhkIv5ZCI6ZuGMzkgICAgICAgIFZOUlRFRzExcm9SUk9oRWtob180cUZQWW8xICAgIFZOUWlRcDRib2hnZU55Rjctb0xyQVVtdW8xIArpq5jmuIXliafpm4ZCL+WQiOmbhjQwICAgICAgICBWTlJURUcxMXJvUlJPaEVraG9fNHFGUFlvMSAgICBWTlFpUmZuREhWX3FxMnkwRjhwZ052RGJvMQrpq5jmuIXliafpm4ZCL+WQiOmbhjQxICAgICAgICBWTlJURlZiUEJHeXcxa3QxSGtpak1vQmtvMSAgICBWTlFpVjBuS09fZTBjUHdDMDJyQnE0dmJvMQ=="
pan115share_list_base64="57qq5b2V54mHIHN3NjJmcmczd3A2IDIyODgzMzE1NDExNTM2NjI1NjQgbjlmNQo0S1JlbXV4IHN3NnB3Nzkzd2ZwIDI2Mjg0NzgyMDk3ODcyNjQzMTUgdzgxNgrnlLXlvbExMDgwUCBzdzY4ZnV1M25udyAxOTI2OTY4MTA1NzIyODIzMDMxIHBiNTcK55S16KeG5YmnIHN3NjhlODEzbm53IDI2NTkwNjMxNzgxMTcyNTAzNzQgbjllMArlkIjpm4YxIHN3enlpd3czd245IDI1MjQ4MTE1NTc1MDA4NTIyNzQgdzFlMArlkIjpm4YyIHN3enlpd3Ezd245IDI2Mzc4OTAyNTgzNzg5MjI3NzcgeDcxNgrlkIjpm4YzIHN3enlpd2Izd245IDI2Mzc4OTYzNjAyMjcyMTU3NDkgcWZlOArliqjnlLvnlLXlvbEgc3d6NmdtbDNmd28gMjc4Mzc1MzU5ODE2NzY3ODE3NiA4ODg4Cuasp+e+jueUteW9sSBzdzY4d3o5M25jYiAyNjU2MjMyMDYwNDAwMzY1NzY4IDY2NjYK576O5YmnIHN3NnBsdDIzbmNiIDI2Mjk4MzAxODUzMjk1NTM3OTYgNjY2NgrljYPpg6jmipbpn7Pnn63liaflkIjpm4Ygc3d6cWg2NzNoNHkgMjg0NDM4ODU0NTQ4Nzk2MTIxMSA1Mjk2CuaKlumfs+efreWJp+WQiOmbhjEuNzdUIHN3eng3NmYzd2ZhIDI5NTUyMjA1NzY3MzcwMDk5NTggbjcyNArml6DmjZ/pn7PkuZAgc3c2dTQweDN3cDYgMjc0ODI0ODM2NTg2NjE1NTczNCB0NTQzCuasp+e+juWJpyBzd3pubTM3M3cxcCAyNzc1NTY3MTE2Njk2MjQ1NDEyIHBlMzUK6Z+z5LmQMjLkuIfpppYgc3d6bXFjcjNmczYgIDI3ODMzMDQ0MDM1ODU1OTY1NjYgeGQ2Nwrpn7PkuZAyMuS4h+mmli9ERFMrSGlSZXMgc3c2NTh1cTM2eDIgMjU2NTY3MjQwMzc2NjAwMTQzNSBtZDk4Cumfs+S5kDIy5LiH6aaWL+avjeW4puezu+WIlyBzdzY1OHVxMzZ4MiAyNTY1NDE2NDc5NzA5MTE3ODQzIG1kOTgK6Z+z5LmQMjLkuIfpppYv57Si5bC857K+6YCJIHN3NjU4dXEzNngyIDI1NjU5MTczNzk1MTUwMzkxNzYgbWQ5OArpn7PkuZAyMuS4h+mmli/lkITnsbvpo47moLwgc3c2NTh1cTM2eDIgMjU2NTQ2NjU4Njk1MzQ2NDg1NyBtZDk4Cumfs+S5kDIy5LiH6aaWL+WNjuivrTI3MDAw6aaW5peg5o2fIHN3NjU4dWIzNngyIDI1NjUyNzQwNTU3ODMzOTg3MzQgcTdlMArml6Xpn6nnlLXlvbEgc3d6ZzhkZDN3eWUgMjkzMjI3Mjg1NzEzNDEzNzEwNyBtNWIzCuaXpemfqeWJpyBzd3pqeGNwM3dmYSAyOTUxODcwNjYzMTk4MzUxNjg2IG9mODk="
quarkshare_list_base64="55S15b2xL+WQiOmbhi/nvo7lm73nlLXlvbHlrabpmaLnmb7lubTnmb7lrrblvbHniYcgIDQwNWNjNWJjNjIyNSAgMzk5YmU1YTMyNDVhNGQxMWE3ODEzMzk0ZjNmOGRjZmIK57uP5YW45b2x6KeG44CQ57O75YiX5aSn54mH5oC75ZCI6ZuG44CRICBiOTQ1ZGQxZmMxZGYgIGFmZGFmNjE4Y2U4ZDQyODdiNjYzYjJmMGVlYzg5NzlmCuWKqOa8qy/liqjmvKvnlLXlvbHlkIjpm4YgYjk0NWRkMWZjMWRmIGI5YTdjYThiODg3NTQwOTA4ZGI2ZDFlNmNlMTQ2ZDYwCuWKqOa8qy/lm73lhoXlpJbnu4/lhbjliqjnlLvliqjmvKvlpKflhaggNmI3OTUyMTgzNDJkIDIzZDk1MTI3MWQ0NjQ2OTdiZTIzMmRiYjc0NmIyMjdlCuWKqOa8qy/lm73mvKvmm7TmlrDkuK0gMTdlOGU5YTFhNjU3IDYzMDUwM2JhM2RjZjRiYjVhZTQ4NWQ2ZWEzN2RjM2Y4CuWKqOa8qy/lt7Llroznu5Plm73mvKsgNmI3OTUyMTgzNDJkIGY2YWI2ZGMwMjEwYTQyYmVhMmRjMmJmZWEzOGMyYmU0CuWKqOa8qy/lt7Llroznu5Pml6XmvKsgNmI3OTUyMTgzNDJkIGQyNjU5NTZlMjQxZTQ5ZGJiYjdiZjVlNzE2MzBiMTkzCuWKqOa8qy/lt7Llroznu5Pnvo7mvKsgNmI3OTUyMTgzNDJkIGM0ZDQyOWRmYzY0NDQ3Mzc4NmJkYjIyYWE2NzQyMTkwCuWwj+WTgeebuOWjsC8yMDI05b635LqR56S+IGVjZTUyZDYzYjY5OCBkYWUyZjM2ZDM2ZDA0NzNiODlmZjg0ZGFhODFiODMwMwrlsI/lk4Hnm7jlo7Av5bCP5ZOB5aSn5ZCI6ZuGIGU4MjcyNjRlYTQ1MyA2MDljNWViOGIzMjQ0ZGMyOTU4YmMxM2YxNmQ0NTRlZArlsI/lk4Hnm7jlo7Av5bCP5ZOB57qv5Lqr5ZCI6ZuGIGQ4YjRhNTg0ZmQxYSBhNTI5OTM0OWQzNjk0MjA2OGFkYzg4Yjk1MmM3YzQ2MQrnlLXlvbEv5ZCI6ZuGL+S7pUFCQ0TlvIDlpLTlkIjpm4YgYTYzMjk2Nzc2MGNmIDdkYTRmZDJkYzA4ZjRmYTU4NTJmOTk3MjE1NTkyNTE3CueUteW9sS/lkIjpm4Yv5LulRUZHSOW8gOWktOWQiOmbhiAyZjU5YmI1ZDk2YjkgN2I3MTczN2UzY2Q4NDNjNWE5MzdhYzk3YTUzNTQyZGQK55S15b2xL+WQiOmbhi/ku6VJSktM5byA5aS05ZCI6ZuGIDUwODI4YzM2OGRlZiAwOTY5NTBlM2QxMDI0MmIxOTY2Yjc3NzgxMTE1YTA3YQrnlLXlvbEv5ZCI6ZuGL+S7pU1OT1DlvIDlpLTlkIjpm4YgZTA3ZTI2YWVjYzA4IGEyYjMwNTMxNjMxYzQ2ZGNiMzlmMzIwNjk3ODk4Mjk1CueUteW9sS/lkIjpm4Yv5LulUVJTVOW8gOWktOWQiOmbhiAwNTM2YTM4YTM1NmUgMWQxNzVkYjMwZWFhNDU0ZTlkYmM1ZWFhMDllMWU0NTQK55S15b2xL+WQiOmbhi/ku6VVVldY5byA5aS05ZCI6ZuGIGUyNzNlZjY5NzQwMyA2ZGJkYTZlODE3ZWI0MTQ1YmEyZGQ2ODFlNTdhYTY3NQrnlLXlvbEv5ZCI6ZuGL+S7pVla5byA5aS05ZCI6ZuGIGM4YWM2Yzg4ZTVkOCA0OGM0NzllMjRiYWU0ZWMzYTRhOWQ1NmZjYjA2ZmNmNArnlLXlvbEv5ZCI6ZuGL+S7peaVsOWtl+W8gOWktOWQiOmbhiA0OWFiNzVkNTJlMDAgY2VjMDcwMmRiMjZiNDdjNWFiZDQyY2E3OWFiYjY1ZTEK55S15b2xL+WvvOa8lCBlZDA4NDRjN2QwNDYgOTA5OTI1NGIxY2VlNGIzOWFjYzZmYzcxZmZmNzcwMzkK55S15b2xL+WvvOa8lC/ljJfph47mraYgZmFiMWVkYjllNWViIGQ3YmJmZmM0NWVmNjQxMDg4ZmU0YjIwMjkxMDhiY2FjCueUteW9sS/lr7zmvJQv5rSq6YeR5a6dIGJlMjYxYzhhN2ViOCBlMWRiOWQ3ODQ4MjI0MmMyOTczZDFjYzIzMDYwY2MxZQrnlLXlvbEv5oGQ5oCW54mHMTAw6YOoIDZjMDY2NmVkMjhkZSA2NjIxOGU3MzEwMTE0OWRmOTczODczYmRjMWY0NjUwMwrnlLXlvbEv5ryU5ZGYL+WImOW+t+WNjiAxNzY0YzJjODE2MDMgYWJhZTJmN2U2MWY1NDk4MDg1MTY3ZTA3ZWY4ZGVjMzQK55S15b2xL+a8lOWRmC/lkajmmJ/pqbAgNjBkY2E1ODAwOWFmIDdkYTUwMmQyNGY0NzRiNjBhZmNjMzQyZmQ1YWMwZGUzCueUteW9sS/mvJTlkZgv5ZGo5ram5Y+RIGU1ODNmYWM0NTU5MiA4MmMwNDljMTQwNTA0ZDRhYTMxY2JmZTE2NDVjYjlkOArnlLXlvbEv5ryU5ZGYL+W8oOWbveiNoyBkMzAwMGYxNDk0MmUgOGMzNWZjYmI0ZTg1NGU1MGIzODVkZjcwMjYwNGQzODIK55S15b2xL+a8lOWRmC/miJDpvpkgZTViNjRkZmIxYzgzIDYwN2I4NzlkYTI1YzQ0NjQ4M2JjN2Y4OTUwY2Q3MzNmCueUteW9sS/mvJTlkZgv5p2O5Li954+NIDQ3MzM3MGU2NTdjMCBjMzlhNTY2MDA5MmU0YmJhYWM3Y2FkM2NmMDY0ZTIzYwrnlLXlvbEv5ryU5ZGYL+adjuWwj+m+mSBiOTQ1ZGQxZmMxZGYgMTcyN2IxNjQ1MTE0NDMxYjgxYTMyZjRkMDZlNDA4MGIK55S15b2xL+a8lOWRmC/mnY7ov57mnbAgYmZjMGE2MTUwYWZjIDZlZWIwMzZjN2Q3YTQ1ODBhYjk1YzE2NWJiZWU3NGMzCueUteW9sS/mvJTlkZgv5rKI6IW+IGI5NDVkZDFmYzFkZiBiODkyYjY5NTNkMjM0ZDRlYWI4NzczNTE5NzI3NWViMQrnlLXlvbEv5ryU5ZGYL+iIkua3hyA4NGU1M2RkMzc4ZjIgYzU5Yzc4MzU4NGU3NGQ3MDk0Yjk4YTY0OTg0OTI4NzYK55S15b2xL+a8lOWRmC/pgrHmt5HotJ4gYzRiMDQwM2MwZGZhIGE5MjBlMDY1NTVmYjRkNTA5NzU3MGNhMWI0MTBiZDAyCueUteW9sS/nsr7pgInpq5jnlLvotKjpq5jliIbnlLXlvbEgOGYxYjRiN2RjNjllIGQyZTVlOTE2NzRmOTQzNTJiMzMxMGFiODZiOGMyMzhlCueUteW9sS/pgrXmsI/lkIjpm4YgNTYxMmZlMWFkYjRhIGVkNDRkMDMzZTNmYzRjNWVhMmQ4YTVjODk1MWRmMGQ5CueUteW9sS/pn6nlm71S57qnIDU0MzJiZWFlNGYxYSA1MTI0ZjQ3ODlkYWY0NTAwOWJkMTMzYWY1MDk5ODEwMgrnlLXlvbEv6auY5YiG5Y2O6K+t55S15b2xMzAw6YOoIGI5NDVkZDFmYzFkZiAyMTk4ZGFiNDNmYzY0YWRiYWY5YTZkNGI1YjEzZWZhYgrnlLXop4bliacvMjAyNOaXpemfqeWJpyA0NWQzNDEzMDE2MGYgZTczODBkM2M3YmM0NDllNmFhNWZhMjMwNjNiMmNkZjMK55S16KeG5YmnLzIwMjTmrKfnvo7liacgZjlmNTQyMGNhYjBkIGZkNjIyZDEyZjUzOTQ5ZWZiNWZlZGUwMmRlMDhlNjQ5CueUteinhuWJpy9UVkLjgIFBVFbkuprop4YgMDg1MjEyZGYzODVkIDE3MmI3ZWNjYzM4NDRhZTRhMTE0NTFkNmExNDVmZmUwCueUteinhuWJpy/lt7Llroznu5Mv5pWw5a2X5byA5aS0IGNkNGM1YWM3ZTgzMCBkZmEwMWNiMTg5NTg0MDhjYTBkYTcyYjEzOTMxOWFmMwrnlLXop4bliacv5bey5a6M57uTL+ixhueTo+ivhOWIhjkuMOS7peS4iuWbveS6p+WJpyBkMTljNGViZTFmZjcgN2I0Mjk0M2Q0ZjIwNDJhYmI5MDdjOTlkZGJiMzU0MGQK55S16KeG5YmnL+W3suWujOe7ky/pppblrZfmr41BQkNEIGUxYjJiYThiNmQ2YyBjODkyNDY3YjBjYzI0YWFiYWNiZWM3MWEwYjZmNGQzYwrnlLXop4bliacv5bey5a6M57uTL+mmluWtl+avjUVGR0ggMTY2ZmEwYTdjYTZmIGZmNTcwODNkODkyMzRlZDM4OTMyZGMwNjA5N2QxMTVkCueUteinhuWJpy/lt7Llroznu5Mv6aaW5a2X5q+NSUpLTCAzN2E5MmMwYjdmMTAgNTg1OTA3YWJhMGVmNDY0YmEwMGEwZjIwYjQ3ZmExMTYK55S16KeG5YmnL+W3suWujOe7ky/pppblrZfmr41OTU9QIGZiMzM4NmU0MmFmMiAzNmUyZjgxZmY0MTQ0YTljOGMxNDk4OGVkODlhODYwZArnlLXop4bliacv5bey5a6M57uTL+mmluWtl+avjVFSU1QgNDZjZTIxNGY0ZWQ3IDNiNGY5ZTBjNjc1OTQ5Yzk5MjY5NDc2ZTVmOWMwN2E4CueUteinhuWJpy/lt7Llroznu5Mv6aaW5a2X5q+NVVZXWCBmZTQ2ODFkN2ZiNDMgYmNiY2ZkMzhkMjU0NGY1Zjk1MWVjZmU0MzA0ODMyMDMK55S16KeG5YmnL+W3suWujOe7ky/pppblrZfmr41ZWiA4ZDY1ZTg4NWIwNTkgMDM2ZmQ5ODk1YzRiNGE0N2E1OWIxNzA0NjcxNTgxNmYK55S16KeG5YmnL+e7j+WFuOaXpemfqeWJp+WQiOmbhiBmMGRiZjU1MzU4NzQgNzY0MjI0YjQxYWZlNGY2ZmJlYTUwYjg4YTNhNmI1MmMK6Z+z5LmQL+S5pummmemfs+S5kOS4lue6quWFuOiXjyBkMmRmYTMyNjQ3ZjYgMTY3YWU5ZWRkM2ZlNDY2MmEyY2UzNzc1NTllMzVmNTgK6Z+z5LmQL+WPpOWFuOmfs+S5kOeyvumAieWQiOmbhiAyYjQ5NzgyMTNiMjkgNjkwMzhmZjA5MDA1NGExZWI4ODAzMTJiZTQ3NzUzOTIK6Z+z5LmQL+Wkp+iHqueEtumfs+S5kOezu+WIl+WQiOmbhiA2NTFlNWZhOTMwNTcgOWM5ZjMzMzY3ODNlNDhhZjlmNDdjNWVjZDk5OGU5MTQK6Z+z5LmQL+e6r+mfs+S5kOWQiOmbhiAxMjg0ODM4MWRjZTEgYWUyY2FlYjc4NDZkNGY4NTg0NjdkMmI2MjZkNzhjYTMK6Z+z5LmQL+i9pui9veaXoOaNn+eOr+e7lemfs+aViOmfs+S5kOWQiOmbhiA4MDVkNzZhMDgwNjMgNTkzZjk4MTA0ZjE5NDMwMmEyN2FlOTFiYTdjZDE4ZGIK6Z+z5LmQL+mch+aSvOW/g+eBteeahOWPsuivl+mfs+S5kOWQiOmbhiBkMWEwYjcwNDZiMjAgMjk0YTUzYTNjOWU4NGVmMGEwYWNjMDQxOTVjMDI1ZDg="

function root_need() {
    if [[ $EUID -ne 0 ]]; then
        ERROR '此脚本必须以 root 身份运行！'
        exit 1
    fi
}

function get_default_network() {

    _default_network=$(cat "${DDSREM_CONFIG_DIR}/default_network.txt")

    if [ "${_default_network}" == "host" ]; then
        echo '--net=host'
    else
        case "${1}" in
        qrcode)
            echo '-p 34256:34256'
            ;;
        xiaoya-proxy)
            echo '-p 9988:9988'
            ;;
        xiaoya-aliyuntvtoken_connector)
            echo '-p 34278:34278'
            ;;
        esac
    fi

}

function check_path() {

    if [ -z "${1}" ]; then
        return 1
    fi

    # 目录不能为‘/’
    if [ "${1}" == "/" ]; then
        return 1
    fi

    # 目录结尾不能有空格
    if [ "${1: -1}" == " " ]; then
        return 1
    fi

    # 目录必须以`/`开头，不能包含`//`或`./`或`..`
    if [[ "${1}" =~ ^/ && ! "${1}" =~ // && ! "${1}" =~ (\./|\.\.) ]]; then
        return 0
    else
        return 1
    fi

}

function get_path() {

    case "${OSNAME}" in
    synology)
        path_lib=/volume1/docker
        ;;
    unraid)
        path_lib=/mnt/user/appdata
        ;;
    fnos)
        if [ -d "/vol1/1000" ]; then
            path_lib=/vol1/1000
        fi
        ;;
    *)
        if auto_path="$(df -h | awk '$2 ~ /G/ && $2+0 > 200 {print $6}' | grep -E -v "Avail|loop|boot|overlay|tmpfs|proc" | head -n 1)" > /dev/null 2>&1; then
            if check_path "${auto_path}"; then
                path_lib="${auto_path}"
            fi
        fi
        ;;
    esac

    if [ -z "${path_lib}" ]; then
        case "${1}" in
        xiaoya_alist_config_dir)
            echo '/etc/xiaoya'
            ;;
        xiaoya_alist_media_dir)
            echo '/opt/media'
            ;;
        esac
    else
        case "${1}" in
        xiaoya_alist_config_dir)
            echo "${path_lib}/xiaoya"
            ;;
        xiaoya_alist_media_dir)
            echo "${path_lib}/xiaoya_emby"
            ;;
        esac
    fi

}

function wait_emby_start() {

    start_time=$(date +%s)
    CONTAINER_NAME="$(cat "${DDSREM_CONFIG_DIR}"/container_name/xiaoya_emby_name.txt)"
    TARGET_LOG_LINE_SUCCESS="All entry points have started"
    while true; do
        line=$(docker logs "$CONTAINER_NAME" 2>&1 | tail -n 10)
        echo -e "$line"
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            break
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ "$elapsed_time" -gt 600 ]; then
            WARN "Emby 未正常启动超时 10 分钟！"
            break
        fi
        sleep 8
    done

}

function wait_xiaoya_start() {

    start_time=$(date +%s)
    TARGET_LOG_LINE_SUCCESS="success load storage: [/©️"
    while true; do
        line=$(docker logs "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" 2>&1 | tail -n 10)
        echo -e "$line"
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [[ "$line" == *"$TARGET_LOG_LINE_SUCCESS"* ]]; then
            if [ "$elapsed_time" -gt 20 ]; then
                break
            fi
        fi
        if [ "$elapsed_time" -gt 600 ]; then
            WARN "小雅alist 未正常启动超时 10 分钟！"
            break
        fi
        sleep 8
    done

}

function check_quark_cookie() {

    if [[ ! -f "${1}/quark_cookie.txt" ]] && [[ ! -s "${1}/quark_cookie.txt" ]]; then
        return 1
    fi
    local cookie user_agent url headers response status url2 response2 member member_type vip_88
    cookie=$(head -n1 "${1}/quark_cookie.txt")
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) quark-cloud-drive/2.5.20 Chrome/100.0.4896.160 Electron/18.3.5.4-b478491100 Safari/537.36 Channel/pckk_other_ch"
    url="https://drive-pc.quark.cn/1/clouddrive/config?pr=ucpro&fr=pc&uc_param_str="
    headers="Cookie: $cookie; User-Agent: $user_agent; Referer: https://pan.quark.cn"
    response=$(curl -s -D - -H "$headers" "$url")
    status=$(echo "$response" | grep -i status | cut -f2 -d: | cut -f1 -d,)
    if [ "$status" == "401" ]; then
        ERROR "无效夸克 Cookie"
        return 1
    elif [ "$status" == "200" ]; then
        url2="https://drive-pc.quark.cn/1/clouddrive/member?pr=ucpro&fr=pc&uc_param_str=&fetch_subscribe=true&_ch=home&fetch_identity=true"
        response2=$(curl -s -H "$headers" "$url2")
        member=$(echo $response2 | grep -o '"member_type":"[^"]*"' | sed 's/"member_type":"\(.*\)"/\1/')
        if [ $member == 'EXP_SVIP' ] || [ $member == 'SVIP' ]; then
            vip_88=$(echo $response2 | grep -o '"vip88_new":[t|f]' | cut -f2 -d:)
            if [ $vip_88 == 't' ]; then
                member_type="88VIP会员"
            else
                member_type="SVIP会员"
            fi
        elif [ $member == 'NORMAL' ]; then
            member_type="普通用户"
        else
            member_type="${member//\"/}会员"
        fi
        INFO "有效 夸克 Cookie，${member_type}"
        return 0
    else
        ERROR "请求失败，请检查 Cookie 或网络连接是否正确。"
        return 1
    fi

}

function check_uc_cookie() {

    if [[ ! -f "${1}/uc_cookie.txt" ]] && [[ ! -s "${1}/uc_cookie.txt" ]]; then
        return 1
    fi
    local cookie user_agent url headers response status referer set_cookie
    cookie=$(head -n1 "${1}/uc_cookie.txt")
    referer="https://drive.uc.cn"
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) quark-cloud-drive/2.5.20 Chrome/100.0.4896.160 Electron/18.3.5.4-b478491100 Safari/537.36 Channel/pckk_other_ch"
    url="https://pc-api.uc.cn/1/clouddrive/file/sort?pr=UCBrowser&fr=pc&pdir_fid=0&_page=1&_size=50&_fetch_total=1&_fetch_sub_dirs=0&_sort=file_type:asc,updated_at:desc"
    headers="Cookie: $cookie; User-Agent: $user_agent; Referer: $referer"
    response=$(curl -s -D - -H "$headers" "$url")
    set_cookie=$(echo "$response" | grep -i "^Set-Cookie:" | sed 's/Set-Cookie: //')
    status=$(echo "$response" | grep -i status | cut -f2 -d: | cut -f1 -d,)
    if [ "$status" == "401" ]; then
        ERROR "无效 UC Cookie"
        return 1
    elif [ -n "${set_cookie}" ]; then
        local new_puus new_cookie
        new_puus=$(echo "$set_cookie" | cut -f2 -d: | cut -f1 -d\;)
        new_cookie=${cookie//__puus=[^;]*/$new_puus}
        echo "$new_cookie" > ${1}/uc_cookie.txt
        INFO "有效 UC Cookie 并更新"
        return 0
    elif [ -z "${set_cookie}" ] && [ "${status}" == "200" ]; then
        INFO "有效 UC Cookie"
        return 0
    else
        ERROR "请求失败，请检查 Cookie 或网络连接是否正确。"
        return 1
    fi

}

function check_115_cookie() {

    if [[ ! -f "${1}/115_cookie.txt" ]] && [[ ! -s "${1}/115_cookie.txt" ]]; then
        return 1
    fi
    local cookie user_agent url headers response vip
    cookie=$(head -n1 "${1}/115_cookie.txt")
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36"
    url="https://my.115.com/?ct=ajax&ac=nav"
    headers="Cookie: $cookie; User-Agent: $user_agent; Referer: https://115.com/"
    response=$(curl -s -D - -H "$headers" "$url")
    vip=$(echo -e "$response" | grep -o '"vip":[^,]*' | sed 's/"vip"://')
    if echo -e "${response}" | grep -q "user_id"; then
        if [ $vip == "0" ]; then
            INFO "有效 115 Cookie，普通用户"
        else
            INFO "有效 115 Cookie，VIP用户"
        fi
        return 0
    else
        ERROR "请求失败，请检查 Cookie 或网络连接是否正确。"
        return 1
    fi

}

function check_aliyunpan_tvtoken() {

    local token url response refresh_token data_dir
    data_dir="${1}"
    if [ -n "${2}" ]; then
        token="${2}"
    else
        token=$(head -n1 "${data_dir}/myopentoken.txt")
    fi
    url=$(head -n1 "${data_dir}/open_tv_token_url.txt")
    if ! response=$(curl -s "${url}" -X POST -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36" -H "Rererer: https://www.aliyundrive.com/" -H "Content-Type: application/json" -d '{"refresh_token":"'$token'", "grant_type": "refresh_token"}'); then
        WARN "网络问题，无法检测 阿里云盘 TV Token 有效性"
        return 0
    fi
    refresh_token=$(echo "$response" | sed 's/:\s*/:/g' | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')
    if [ -n "${refresh_token}" ]; then
        echo "${refresh_token}" > "${data_dir}/myopentoken.txt"
        INFO "有效 阿里云盘 TV Token"
        return 0
    else
        ERROR "无效 阿里云盘 TV Token"
        return 1
    fi

}

function check_aliyunpan_refreshtoken() {

    local token header referer response refresh_token data_dir
    data_dir="${1}"
    if [ -n "${2}" ]; then
        token="${2}"
    else
        token=$(head -n1 "${data_dir}/mytoken.txt")
    fi
    header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.54 Safari/537.36"
    referer=https://www.aliyundrive.com/
    if ! response=$(curl -s https://auth.aliyundrive.com/v2/account/token -X POST -H "User-Agent: $header" -H "Content-Type:application/json" -H "Referer: $referer" -d '{"refresh_token":"'$token'", "grant_type": "refresh_token"}'); then
        WARN "网络问题，无法检测 阿里云盘 Refresh Token 有效性"
        return 0
    fi
    refresh_token=$(echo "$response" | sed 's/:\s*/:/g' | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')
    if [ -n "${refresh_token}" ]; then
        echo "${refresh_token}" > "${data_dir}/mytoken.txt"
        INFO "有效 阿里云盘 Refresh Token"
        return 0
    else
        ERROR "无效 阿里云盘 Refresh Token"
        return 1
    fi

}

function check_aliyunpan_opentoken() {

    local token code response refresh_token data_dir
    data_dir="${1}"
    if [ -n "${2}" ]; then
        token="${2}"
    else
        token=$(head -n1 "${data_dir}/myopentoken.txt")
    fi
    if ! response=$(curl -s "https://api.xhofe.top/alist/ali_open/token" -X POST -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36" -H "Rererer: https://www.aliyundrive.com/" -H "Content-Type: application/json" -d '{"refresh_token":"'$token'", "grant_type": "refresh_token"}'); then
        if ! response=$(curl -s "https://api-cf.nn.ci/alist/ali_open/token" -X POST -H "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36" -H "Rererer: https://www.aliyundrive.com/" -H "Content-Type: application/json" -d '{"refresh_token":"'$token'", "grant_type": "refresh_token"}'); then
            WARN "网络问题，无法检测 阿里云盘 Open Token 有效性"
            return 0
        fi
    fi
    code=$(echo "$response" | sed -n 's/.*"code":"\([^"]*\).*/\1/p')
    refresh_token=$(echo "$response" | sed 's/:\s*/:/g' | sed -n 's/.*"refresh_token":"\([^"]*\).*/\1/p')
    if [ -n "${refresh_token}" ]; then
        echo "${refresh_token}" > "${data_dir}/myopentoken.txt"
        INFO "有效 阿里云盘 Open Token"
        return 0
    elif [ "${code}" == "Too Many Requests" ]; then
        WARN "已被限流，无法检测 阿里云盘 Open Token 有效性"
        return 0
    else
        ERROR "无效 阿里云盘 Open Token"
        return 1
    fi

}

function qrcode_mode_choose() {

    function qrcode_web() {

        if ! check_port "34256"; then
            ERROR "34256 端口被占用，请关闭占用此端口的程序！"
            exit 1
        fi

        local local_ip
        if [[ "${OSNAME}" = "macos" ]]; then
            local_ip=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
        else
            local_ip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
        fi
        if [ -z "${local_ip}" ]; then
            local_ip="小雅服务器IP"
        fi
        INFO "请浏览器访问 http://${local_ip}:34256 并使用阿里云盘APP扫描二维码！"
        # shellcheck disable=SC2046
        docker run -i --rm \
            -v "${1}:/data" \
            -e LANG=C.UTF-8 \
            $(get_default_network "qrcode") \
            ddsderek/xiaoya-glue:python \
            "${2}" --qrcode_mode=web

    }

    if [ "${2}" == "/aliyuntoken/aliyuntoken_vercel.py" ]; then
        WARN "当前模式只能浏览器扫码！"
        qrcode_web "${1}" "${2}"
    fi

    while true; do
        INFO "请选择扫码模式 [ 1: 命令行扫码 | 2: 浏览器扫码 ]（默认 2）"
        read -erp "QRCODE_MODE:" QRCODE_MODE
        [[ -z "${QRCODE_MODE}" ]] && QRCODE_MODE="2"
        if [[ ${QRCODE_MODE} == [1] ]]; then
            docker run -i --rm \
                -v "${1}:/data" \
                -e LANG=C.UTF-8 \
                ddsderek/xiaoya-glue:python \
                "${2}" --qrcode_mode=shell
            return 0
        elif [[ ${QRCODE_MODE} == [2] ]]; then
            qrcode_web "${1}" "${2}"
            return 0
        else
            ERROR "输入无效，请重新选择"
        fi
    done

}

function qrcode_aliyunpan_tvtoken() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "阿里云盘 TV Token 配置"
        pull_glue_python_ddsrem
        qrcode_mode_choose "${1}" "/aliyuntvtoken/alitoken2.py"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前阿里云盘 TV Token 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function qrcode_aliyunpan_refreshtoken() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "阿里云盘 Refresh Token 配置"
        local command_file
        pull_glue_python_ddsrem
        if curl -Is https://api.xhofe.top/alist/ali/qr | head -n 1 | grep -q '200'; then
            command_file="aliyuntoken.py"
            INFO "使用 api.xhofe.top 地址"
        elif curl -Is https://api-cf.nn.ci/alist/ali/qr | head -n 1 | grep -q '200'; then
            command_file="aliyuntoken_nn.ci.py"
            INFO "使用 api-cf.nn.ci 地址"
        else
            command_file="aliyuntoken_vercel.py"
            INFO "使用 aliyuntoken.vercel.app 地址"
        fi
        qrcode_mode_choose "${1}" "/aliyuntoken/${command_file}"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前阿里云盘 Refresh Token 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function qrcode_aliyunpan_opentoken() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "阿里云盘 Open Token 配置"
        local command_file
        pull_glue_python_ddsrem
        if curl -Is https://api.xhofe.top/alist/ali_open/qr | head -n 1 | grep -q '200'; then
            command_file="aliyunopentoken.py"
            INFO "使用 api.xhofe.top 地址"
        else
            command_file="aliyunopentoken_nn.ci.py"
            INFO "使用 api-cf.nn.ci 地址"
        fi
        qrcode_mode_choose "${1}" "/aliyunopentoken/${command_file}"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前阿里云盘 Open Token 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function qrcode_115_cookie() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "115 Cookie 扫码获取"
        pull_glue_python_ddsrem
        qrcode_mode_choose "${1}" "/115cookie/115cookie.py"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前 115 Cookie 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function qrcode_quark_cookie() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "夸克 Cookie 扫码获取"
        pull_glue_python_ddsrem
        qrcode_mode_choose "${1}" "/quark_cookie/quark_cookie.py"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前夸克 Cookie 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function qrcode_uc_cookie() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "UC Cookie 扫码获取"
        pull_glue_python_ddsrem
        qrcode_mode_choose "${1}" "/uc_cookie/uc_cookie.py"
        INFO "操作全部完成！"
        ;;
    *)
        WARN "目前 UC Cookie 扫码获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function enter_aliyunpan_refreshtoken() {

    while true; do
        INFO "是否使用扫码自动获取 阿里云盘 Token [Y/n]（默认 Y）"
        read -erp "Token:" choose_qrcode_aliyunpan_refreshtoken
        [[ -z "${choose_qrcode_aliyunpan_refreshtoken}" ]] && choose_qrcode_aliyunpan_refreshtoken="y"
        if [[ ${choose_qrcode_aliyunpan_refreshtoken} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${choose_qrcode_aliyunpan_refreshtoken} == [Yy] ]]; then
        qrcode_aliyunpan_refreshtoken "${1}"
    fi
    mytokenfilesize=$(cat "${1}"/mytoken.txt)
    mytokenstringsize=${#mytokenfilesize}
    if [ "$mytokenstringsize" -le 31 ] || ! check_aliyunpan_refreshtoken "${1}"; then
        if [[ ${choose_qrcode_aliyunpan_refreshtoken} == [Yy] ]]; then
            WARN "扫码获取 阿里云盘 Token 失败，请手动获取！"
        fi
        while true; do
            INFO "输入你的 阿里云盘 Token（32位长）"
            read -erp "TOKEN:" token
            token_len=${#token}
            if [ "$token_len" -ne 32 ]; then
                ERROR "长度不对,阿里云盘 Token是32位长"
                ERROR "请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            else
                echo "$token" > "${1}"/mytoken.txt
                if check_aliyunpan_refreshtoken "${1}"; then
                    break
                fi
            fi
        done
    fi

}

function settings_aliyunpan_refreshtoken() {

    if [ "${2}" == "force" ]; then
        enter_aliyunpan_refreshtoken "${1}"
    else
        mytokenfilesize=$(cat "${1}"/mytoken.txt)
        mytokenstringsize=${#mytokenfilesize}
        if [ "$mytokenstringsize" -le 31 ] || ! check_aliyunpan_refreshtoken "${1}"; then
            enter_aliyunpan_refreshtoken "${1}"
        fi
    fi

}

function enter_aliyunpan_opentoken() {

    while true; do
        INFO "是否使用扫码自动获取 阿里云盘 Open Token [Y/n]（默认 Y）"
        read -erp "Token:" choose_qrcode_aliyunpan_opentoken
        [[ -z "${choose_qrcode_aliyunpan_opentoken}" ]] && choose_qrcode_aliyunpan_opentoken="y"
        if [[ ${choose_qrcode_aliyunpan_opentoken} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${choose_qrcode_aliyunpan_opentoken} == [Yy] ]]; then
        qrcode_aliyunpan_opentoken "${1}"
    fi
    myopentokenfilesize=$(cat "${1}"/myopentoken.txt)
    myopentokenstringsize=${#myopentokenfilesize}
    if [ "$myopentokenstringsize" -le 279 ] || ! check_aliyunpan_opentoken "${1}"; then
        if [[ ${choose_qrcode_aliyunpan_opentoken} == [Yy] ]]; then
            WARN "扫码获取 阿里云盘 Open Token 失败，请手动获取！"
        fi
        while true; do
            INFO "输入你的 阿里云盘 Open Token（280位长或者335位长）"
            read -erp "OPENTOKEN:" opentoken
            opentoken_len=${#opentoken}
            if [[ "$opentoken_len" -ne 280 ]] && [[ "$opentoken_len" -ne 335 ]]; then
                ERROR "长度不对,阿里云盘 Open Token是280位长或者335位"
                ERROR "请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            else
                echo "$opentoken" > "${1}"/myopentoken.txt
                if check_aliyunpan_opentoken "${1}"; then
                    break
                fi
            fi
        done
    fi

}

function settings_aliyunpan_opentoken() {

    if [ -f "${1}/open_tv_token_url.txt" ]; then
        mv "${1}/open_tv_token_url.txt" "${1}/open_tv_token_url.txt.bak"
    fi

    if [ "${2}" == "force" ]; then
        enter_aliyunpan_opentoken "${1}"
    else
        myopentokenfilesize=$(cat "${1}"/myopentoken.txt)
        myopentokenstringsize=${#myopentokenfilesize}
        if [ "$myopentokenstringsize" -le 279 ] || ! check_aliyunpan_opentoken "${1}"; then
            enter_aliyunpan_opentoken "${1}"
        fi
    fi

}

function enter_115_cookie() {

    touch ${1}/115_cookie.txt
    while true; do
        INFO "是否使用扫码自动获取 115 Cookie [Y/n]（默认 Y）"
        read -erp "Cookie:" choose_qrcode_115_cookie
        [[ -z "${choose_qrcode_115_cookie}" ]] && choose_qrcode_115_cookie="y"
        if [[ ${choose_qrcode_115_cookie} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${choose_qrcode_115_cookie} == [Yy] ]]; then
        qrcode_115_cookie "${1}"
    fi
    if ! check_115_cookie "${1}"; then
        if [[ ${choose_qrcode_115_cookie} == [Yy] ]]; then
            WARN "扫码获取 115 Cookie 失败，请手动获取！"
        fi
        while true; do
            INFO "输入你的 115 Cookie"
            read -erp "Cookie:" set_115_cookie
            echo -e "${set_115_cookie}" > ${1}/115_cookie.txt
            if check_115_cookie "${1}"; then
                break
            fi
        done
    fi

}

function settings_115_cookie() {

    if [ "${2}" == "force" ]; then
        enter_115_cookie "${1}"
    else
        if [ ! -f "${1}/115_cookie.txt" ] || ! check_115_cookie "${1}"; then
            while true; do
                INFO "是否配置 115 Cookie [Y/n]（默认 n 不配置）"
                read -erp "Cookie:" choose_115_cookie
                [[ -z "${choose_115_cookie}" ]] && choose_115_cookie="n"
                if [[ ${choose_115_cookie} == [YyNn] ]]; then
                    break
                else
                    ERROR "非法输入，请输入 [Y/n]"
                fi
            done
            if [[ ${choose_115_cookie} == [Yy] ]]; then
                enter_115_cookie "${1}"
            fi
        fi
    fi

}

function enter_quark_cookie() {

    touch ${1}/quark_cookie.txt
    while true; do
        INFO "是否使用扫码自动获取 夸克 Cookie [Y/n]（默认 Y）"
        read -erp "Cookie:" choose_qrcode_quark_cookie
        [[ -z "${choose_qrcode_quark_cookie}" ]] && choose_qrcode_quark_cookie="y"
        if [[ ${choose_qrcode_quark_cookie} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${choose_qrcode_quark_cookie} == [Yy] ]]; then
        qrcode_quark_cookie "${1}"
    fi
    if ! check_quark_cookie "${1}"; then
        if [[ ${choose_qrcode_quark_cookie} == [Yy] ]]; then
            WARN "扫码获取 夸克 Cookie 失败，请手动获取！"
        fi
        while true; do
            INFO "输入你的 夸克 Cookie"
            read -erp "Cookie:" quark_cookie
            echo -e "${quark_cookie}" > ${1}/quark_cookie.txt
            if check_quark_cookie "${1}"; then
                break
            fi
        done
    fi

}

function settings_quark_cookie() {

    if [ "${2}" == "force" ]; then
        enter_quark_cookie "${1}"
    else
        if [ ! -f "${1}/quark_cookie.txt" ] || ! check_quark_cookie "${1}"; then
            while true; do
                INFO "是否配置 夸克 Cookie [Y/n]（默认 n 不配置）"
                read -erp "Cookie:" choose_quark_cookie
                [[ -z "${choose_quark_cookie}" ]] && choose_quark_cookie="n"
                if [[ ${choose_quark_cookie} == [YyNn] ]]; then
                    break
                else
                    ERROR "非法输入，请输入 [Y/n]"
                fi
            done
            if [[ ${choose_quark_cookie} == [Yy] ]]; then
                enter_quark_cookie "${1}"
            fi
        fi
    fi

}

function enter_uc_cookie() {

    touch ${1}/uc_cookie.txt
    while true; do
        INFO "是否使用扫码自动获取 UC Cookie [Y/n]（默认 Y）"
        read -erp "Cookie:" choose_qrcode_uc_cookie
        [[ -z "${choose_qrcode_uc_cookie}" ]] && choose_qrcode_uc_cookie="y"
        if [[ ${choose_qrcode_uc_cookie} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${choose_qrcode_uc_cookie} == [Yy] ]]; then
        qrcode_uc_cookie "${1}"
    fi
    if ! check_uc_cookie "${1}"; then
        if [[ ${choose_qrcode_uc_cookie} == [Yy] ]]; then
            WARN "扫码获取 UC Cookie 失败，请手动获取！"
        fi
        while true; do
            INFO "输入你的 UC Cookie"
            read -erp "Cookie:" uc_cookie
            echo -e "${uc_cookie}" > ${1}/uc_cookie.txt
            if check_uc_cookie "${1}"; then
                break
            fi
        done
    fi

}

function settings_uc_cookie() {

    if [ "${2}" == "force" ]; then
        enter_uc_cookie "${1}"
    else
        if [ ! -f "${1}/uc_cookie.txt" ] || ! check_uc_cookie "${1}"; then
            while true; do
                INFO "是否配置 UC Cookie [Y/n]（默认 n 不配置）"
                read -erp "Cookie:" choose_uc_cookie
                [[ -z "${choose_uc_cookie}" ]] && choose_uc_cookie="n"
                if [[ ${choose_uc_cookie} == [YyNn] ]]; then
                    break
                else
                    ERROR "非法输入，请输入 [Y/n]"
                fi
            done
            if [[ ${choose_uc_cookie} == [Yy] ]]; then
                enter_uc_cookie "${1}"
            fi
        fi
    fi

}

function enter_pikpak_account() {

    touch ${1}/pikpak.txt
    INFO "输入你的 PikPak 账号（手机号或邮箱）"
    INFO "如果手机号，要\"+区号\"，比如你的手机号\"12345678900\"那么就填\"+8612345678900\""
    read -erp "PikPak_Username:" PikPak_Username
    INFO "输入你的 PikPak 账号密码"
    read -erp "PikPak_Password:" PikPak_Password
    INFO "输入你的 PikPak X-Device-Id"
    read -erp "PikPak_Device_Id:" PikPak_Device_Id
    echo -e "\"${PikPak_Username}\" \"${PikPak_Password}\" \"web\" \"${PikPak_Device_Id}\"" > ${1}/pikpak.txt

}

function settings_pikpak_account() {

    if [ "${2}" == "force" ]; then
        enter_pikpak_account "${1}"
    else
        if [ ! -f "${1}/pikpak.txt" ]; then
            while true; do
                INFO "是否继续配置 PikPak 账号密码 [Y/n]（默认 n 不配置）"
                read -erp "PikPak_Set:" PikPak_Set
                [[ -z "${PikPak_Set}" ]] && PikPak_Set="n"
                if [[ ${PikPak_Set} == [YyNn] ]]; then
                    break
                else
                    ERROR "非法输入，请输入 [Y/n]"
                fi
            done
            if [[ ${PikPak_Set} == [Yy] ]]; then
                enter_pikpak_account "${1}"
            fi
        fi
    fi

}

function enter_ali2115() {

    touch ${1}/ali2115.txt
    if [ -f "${1}/115_cookie.txt" ] && check_115_cookie "${1}"; then
        INFO "自动获取 115 Cookie！"
        set_115_cookie="$(cat ${1}/115_cookie.txt | head -n1)"
    else
        while true; do
            INFO "输入你的 115 Cookie"
            read -erp "Cookie:" set_115_cookie
            if [ -n "${set_115_cookie}" ]; then
                break
            fi
        done
    fi
    while true; do
        INFO "是否自动删除115转存文件 [Y/n]（默认 Y）"
        read -erp "purge_pan115_temp:" purge_pan115_temp
        [[ -z "${purge_pan115_temp}" ]] && purge_pan115_temp="y"
        if [[ ${purge_pan115_temp} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    while true; do
        INFO "是否自动删除阿里云盘转存文件 [Y/n]（默认 Y）"
        read -erp "purge_ali_temp:" purge_ali_temp
        [[ -z "${purge_ali_temp}" ]] && purge_ali_temp="y"
        if [[ ${purge_ali_temp} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    INFO "输入你的 115 转存文件夹 id（默认 0）"
    read -erp "dir_id:" dir_id
    [[ -z "${dir_id}" ]] && dir_id=0
    if [[ ${purge_pan115_temp} == [Yy] ]]; then
        purge_pan115_temp=true
    else
        purge_pan115_temp=false
    fi
    if [[ ${purge_ali_temp} == [Yy] ]]; then
        purge_ali_temp=true
    else
        purge_ali_temp=false
    fi
    echo -e "purge_ali_temp=${purge_ali_temp}\ncookie=\"${set_115_cookie}\"\npurge_pan115_temp=${purge_pan115_temp}\ndir_id=${dir_id}" > ${1}/ali2115.txt

}

function settings_ali2115() {

    if [ "${2}" == "force" ]; then
        enter_ali2115 "${1}"
    else
        if [ ! -f "${1}/ali2115.txt" ]; then
            while true; do
                INFO "是否配置 阿里转存115播放（ali2115.txt） [Y/n]（默认 n 不配置）"
                read -erp "ali2115:" ali2115_set
                [[ -z "${ali2115_set}" ]] && ali2115_set="n"
                if [[ ${ali2115_set} == [YyNn] ]]; then
                    break
                else
                    ERROR "非法输入，请输入 [Y/n]"
                fi
            done
            if [[ ${ali2115_set} == [Yy] ]]; then
                enter_ali2115 "${1}"
            fi
        fi
    fi

}

function get_aliyunpan_folder_id() {

    clear_qrcode_container
    cpu_arch=$(uname -m)
    case $cpu_arch in
    "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "阿里云盘 folder id 自动获取"
        pull_glue_python_ddsrem
        docker run -i --rm \
            -v "${1}:/data" \
            -e LANG=C.UTF-8 \
            ddsderek/xiaoya-glue:python \
            bash /get_folder_id/get_folder_id.sh
        ;;
    *)
        WARN "目前阿里云盘 folder id 自动获取只支持amd64和arm64架构，你的架构是：$cpu_arch"
        ;;
    esac

}

function get_config_dir() {

    local xiaoya_config_dir DEFAULT_CONFIG_DIR

    if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
        xiaoya_config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data$" | awk -F: '{print $1}')"
    fi

    while true; do
        if [ -n "${xiaoya_config_dir}" ]; then
            if [ ! -f "${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt" ] || [ -z "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)" ]; then
                echo "${xiaoya_config_dir}" > "${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt"
            fi
            if [ "${xiaoya_config_dir}" == "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)" ]; then
                INFO "小雅容器挂载目录与当前保存的小雅配置目录路径一致"
                INFO "小雅配置目录通过小雅容器获取"
            else
                WARN "小雅容器挂载目录与当前保存的小雅配置目录路径不一致"
                WARN "默认使用当前保存的小雅配置目录路径"
            fi
            xiaoya_config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            INFO "已读取小雅Alist配置文件路径：${xiaoya_config_dir} (默认不更改回车继续，如果需要更改请输入新路径)"
            read -erp "CONFIG_DIR:" CONFIG_DIR
            [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${xiaoya_config_dir}
        elif [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            INFO "已读取小雅Alist配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
            read -erp "CONFIG_DIR:" CONFIG_DIR
            [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        else
            DEFAULT_CONFIG_DIR="$(get_path "xiaoya_alist_config_dir")"
            INFO "请输入配置文件目录（默认 ${DEFAULT_CONFIG_DIR} ）"
            read -erp "CONFIG_DIR:" CONFIG_DIR
            [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="${DEFAULT_CONFIG_DIR}"
            touch "${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt"
        fi
        if check_path "${CONFIG_DIR}"; then
            echo "${CONFIG_DIR}" > "${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt"
            INFO "目录合法性检测通过！"
            break
        else
            ERROR "非合法目录，请重新输入！"
        fi
    done
    if [ -d "${CONFIG_DIR}" ]; then
        INFO "读取配置目录中..."
        # 将所有小雅配置文件修正成 linux 格式
        if [[ "${OSNAME}" = "macos" ]]; then
            find ${CONFIG_DIR} -maxdepth 1 -type f -name "*.txt" -exec sed -i '' "s/\r$//g" {} \;
        else
            find ${CONFIG_DIR} -maxdepth 1 -type f -name "*.txt" -exec sed -i "s/\r$//g" {} \;
        fi
        # 设置权限
        find ${CONFIG_DIR} -maxdepth 1 -type f -exec chmod 777 {} \;
    fi

}

function get_media_dir() {

    local media_dir DEFAULT_MEDIA_DIR

    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
            # shellcheck disable=SC1091
            source "${XIAOYA_CONFIG_DIR}/emby_config.txt"
            # shellcheck disable=SC2154
            echo "${media_dir}" > ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt
            INFO "媒体库目录通过 emby_config.txt 获取"
        fi
    fi

    while true; do
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
            OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
            INFO "已读取媒体库目录：${OLD_MEDIA_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
            read -erp "MEDIA_DIR:" MEDIA_DIR
            [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR=${OLD_MEDIA_DIR}
        else
            DEFAULT_MEDIA_DIR="$(get_path "xiaoya_alist_media_dir")"
            INFO "请输入媒体库目录（默认 ${DEFAULT_MEDIA_DIR} ）"
            read -erp "MEDIA_DIR:" MEDIA_DIR
            [[ -z "${MEDIA_DIR}" ]] && MEDIA_DIR="${DEFAULT_MEDIA_DIR}"
            touch "${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt"
        fi
        if check_path "${MEDIA_DIR}"; then
            echo "${MEDIA_DIR}" > "${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt"
            INFO "目录合法性检测通过！"
            break
        else
            ERROR "非合法目录，请重新输入！"
        fi
    done

}

function main_account_management() {

    clear

    local config_dir
    if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
        config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data$" | awk -F: '{print $1}')"
    fi
    if [ -z "${config_dir}" ]; then
        get_config_dir
        config_dir=${CONFIG_DIR}
    fi

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}账号管理${Font}\n"
    echo -e "${Sky_Blue}小雅留言，会员购买指南：
基础版：阿里非会员+115会员+夸克88vip
升级版：阿里svip+115会员+夸克88vip（用TV token破解阿里svip的高速流量限制）
豪华版：阿里svip+第三方权益包+115会员+夸克svip
乞丐版：满足看emby画报但不要播放，播放用tvbox各种免费源${Font}\n"
    echo -ne "${INFO} 界面加载中...${Font}\r"
    echo -e "1、115 Cookie                        （当前：$(if CHECK_OUT=$(check_115_cookie "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}错误${Font}"; fi)）
2、夸克 Cookie                       （当前：$(if CHECK_OUT=$(check_quark_cookie "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}错误${Font}"; fi)）
3、阿里云盘 Refresh Token（mytoken） （当前：$(if CHECK_OUT=$(check_aliyunpan_refreshtoken "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}错误${Font}"; fi))）
4、阿里云盘 Open Token（myopentoken）（当前：$(if [ -f "${config_dir}/myopentoken.txt" ]; then if [ -f "${config_dir}/open_tv_token_url.txt" ]; then if CHECK_OUT=$(check_aliyunpan_tvtoken "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}阿里云盘 TV Token 已失效${Font}"; fi; elif CHECK_OUT=$(check_aliyunpan_opentoken "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}阿里云盘 Open Token 已失效${Font}"; fi; else echo -e "${Red}未配置${Font}"; fi)）
5、UC Cookie                         （当前：$(if CHECK_OUT=$(check_uc_cookie "${config_dir}"); then echo -e "${Green}$(echo -e ${CHECK_OUT} | sed 's/\[.*\] //')${Font}"; else echo -e "${Red}错误${Font}"; fi)）
6、PikPak                            （当前：$(if [ -f "${config_dir}/pikpak.txt" ]; then echo -e "${Green}已配置${Font}"; else echo -e "${Red}未配置${Font}"; fi)）
7、阿里转存115播放（ali2115.txt）    （当前：$(if [ -f "${config_dir}/ali2115.txt" ]; then echo -e "${Green}已配置${Font}"; else echo -e "${Red}未配置${Font}"; fi)）"
    echo -e "8、应用配置（自动重启小雅，并返回上级菜单）"
    echo -e "0、返回上级（从此处退出不会重启小雅，如果更改了上述配置请手动重启）"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-8]:" num
    case "$num" in
    1)
        clear
        settings_115_cookie "${config_dir}" force
        main_account_management
        ;;
    2)
        clear
        settings_quark_cookie "${config_dir}" force
        main_account_management
        ;;
    3)
        clear
        settings_aliyunpan_refreshtoken "${config_dir}" force
        main_account_management
        ;;
    4)
        clear
        settings_aliyunpan_opentoken "${config_dir}" force
        main_account_management
        ;;
    5)
        clear
        settings_uc_cookie "${config_dir}" force
        main_account_management
        ;;
    6)
        clear
        settings_pikpak_account "${config_dir}" force
        main_account_management
        ;;
    7)
        clear
        settings_ali2115 "${config_dir}" force
        main_account_management
        ;;
    8)
        clear
        if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
            INFO "重启小雅容器中..."
            docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
            wait_xiaoya_start
        else
            WARN "您未安装小雅，请先安装小雅容器！"
        fi
        if docker container inspect xiaoya-115cleaner > /dev/null 2>&1; then
            docker restart xiaoya-115cleaner
        fi
        INFO "配置保存完成，按任意键返回菜单！"
        read -rs -n 1 -p ""
        clear
        main_xiaoya_alist
        ;;
    0)
        clear
        main_xiaoya_alist
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-8]'
        main_account_management
        ;;
    esac

}

function install_xiaoya_alist() {

    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    else
        if [ -d "${CONFIG_DIR}"/mytoken.txt ]; then
            rm -rf "${CONFIG_DIR}"/mytoken.txt
        fi
    fi

    if [ ! -d "${CONFIG_DIR}/data" ]; then
        mkdir -p "${CONFIG_DIR}/data"
    fi

    files=("mytoken.txt" "myopentoken.txt" "temp_transfer_folder_id.txt")
    for file in "${files[@]}"; do
        if [ ! -f "${CONFIG_DIR}/${file}" ]; then
            touch "${CONFIG_DIR}/${file}"
        fi
    done

    settings_aliyunpan_refreshtoken "${CONFIG_DIR}"

    if [ -f "${CONFIG_DIR}/open_tv_token_url.txt" ]; then
        check_aliyunpan_tvtoken "${CONFIG_DIR}"
    else
        settings_aliyunpan_opentoken "${CONFIG_DIR}"
    fi

    folderidfilesize=$(cat "${CONFIG_DIR}"/temp_transfer_folder_id.txt)
    folderidstringsize=${#folderidfilesize}
    if [ "$folderidstringsize" -le 39 ]; then
        while true; do
            INFO "输入你的阿里云盘转存目录 folder id（留空自动获取）"
            read -erp "FOLDERID:" folderid
            if [ -z "${folderid}" ]; then
                get_aliyunpan_folder_id "${CONFIG_DIR}"
                folderid=$(cat "${CONFIG_DIR}"/temp_transfer_folder_id.txt)
            fi
            folder_id_len=${#folderid}
            if [ "$folder_id_len" -ne 40 ]; then
                ERROR "长度不对，阿里云盘 folder id 是40位长"
                ERROR "请参考指南配置文件: https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f"
            else
                echo "$folderid" > "${CONFIG_DIR}"/temp_transfer_folder_id.txt
                break
            fi
        done
    fi

    settings_pikpak_account "${CONFIG_DIR}"

    if [ -f "${CONFIG_DIR}/pikpak.txt" ] && [ ! -f "${CONFIG_DIR}/pikpakshare_list.txt" ] && command -v base64 > /dev/null 2>&1; then
        while true; do
            INFO "是否使用小雅官方分享的 pikpakshare_list.txt 文件 [Y/n]（默认 y）"
            read -erp "pikpakshare_list_choose:" pikpakshare_list_choose
            [[ -z "${pikpakshare_list_choose}" ]] && pikpakshare_list_choose="y"
            if [[ ${pikpakshare_list_choose} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${pikpakshare_list_choose} == [Yy] ]]; then
            echo "${pikpakshare_list_base64}" | base64 --decode > "${CONFIG_DIR}/pikpakshare_list.txt"
        fi
    fi

    settings_quark_cookie "${CONFIG_DIR}"

    if [ -f "${CONFIG_DIR}/quark_cookie.txt" ] && [ ! -f "${CONFIG_DIR}/quarkshare_list.txt" ] && command -v base64 > /dev/null 2>&1; then
        while true; do
            INFO "是否使用小雅官方分享的 quarkshare_list.txt 文件 [Y/n]（默认 y）"
            read -erp "quarkshare_list_choose:" quarkshare_list_choose
            [[ -z "${quarkshare_list_choose}" ]] && quarkshare_list_choose="y"
            if [[ ${quarkshare_list_choose} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${quarkshare_list_choose} == [Yy] ]]; then
            echo "${quarkshare_list_base64}" | base64 --decode > "${CONFIG_DIR}/quarkshare_list.txt"
        fi
    fi

    settings_uc_cookie "${CONFIG_DIR}"

    settings_115_cookie "${CONFIG_DIR}"

    if [ -f "${CONFIG_DIR}/115_cookie.txt" ] && [ ! -f "${CONFIG_DIR}/115share_list.txt" ] && command -v base64 > /dev/null 2>&1; then
        while true; do
            INFO "是否使用小雅官方分享的 115share_list.txt 文件 [Y/n]（默认 y）"
            read -erp "pan115share_list_choose:" pan115share_list_choose
            [[ -z "${pan115share_list_choose}" ]] && pan115share_list_choose="y"
            if [[ ${pan115share_list_choose} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${pan115share_list_choose} == [Yy] ]]; then
            echo "${pan115share_list_base64}" | base64 --decode > "${CONFIG_DIR}/115share_list.txt"
        fi
    fi

    settings_ali2115 "${CONFIG_DIR}"

    if [[ "${OSNAME}" = "macos" ]]; then
        localip=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
    else
        if command -v ifconfig > /dev/null 2>&1; then
            localip=$(ifconfig -a | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1)
        else
            localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
        fi
    fi
    INFO "本地IP：${localip}"

    ports=(5678 2345 2346 2347)
    for port in "${ports[@]}"; do
        if ! check_port "${port}"; then
            check_ports_result=false
        fi
    done
    if [ "${check_ports_result}" == false ]; then
        exit 1
    fi

    if [ "${SET_NET_MODE}" == true ]; then
        while true; do
            INFO "是否使用host网络模式 [Y/n]（默认 n 不使用）"
            read -erp "NET_MODE:" NET_MODE
            [[ -z "${NET_MODE}" ]] && NET_MODE="n"
            if [[ ${NET_MODE} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
    fi
    if [ ! -s "${CONFIG_DIR}"/docker_address.txt ]; then
        echo "http://$localip:5678" > "${CONFIG_DIR}"/docker_address.txt
    fi
    docker_command=("docker run" "-itd")
    if [[ ${NET_MODE} == [Yy] ]]; then
        docker_image="xiaoyaliu/alist:hostmode"
        docker_command+=("--network=host")
    else
        docker_image="xiaoyaliu/alist:latest"
        docker_command+=("-p 5678:80" "-p 2345:2345" "-p 2346:2346" "-p 2347:2347")
    fi
    if [[ -f ${CONFIG_DIR}/proxy.txt ]] && [[ -s ${CONFIG_DIR}/proxy.txt ]]; then
        proxy_url=$(head -n1 "${CONFIG_DIR}"/proxy.txt)
        docker_command+=("--env HTTP_PROXY=$proxy_url" "--env HTTPS_PROXY=$proxy_url" "--env no_proxy=*.aliyundrive.com")
    fi
    docker_command+=("-v ${CONFIG_DIR}:/data" "-v ${CONFIG_DIR}/data:/www/data" "--restart=always" "--name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" "$docker_image")
    docker_pull "$docker_image"
    if eval "${docker_command[*]}"; then
        wait_xiaoya_start
        INFO "安装完成！"
        INFO "服务已成功启动，您可以根据使用需求尝试访问以下的地址："
        INFO "alist: ${Sky_Blue}http://ip:5678${Font}"
        INFO "webdav: ${Sky_Blue}http://ip:5678/dav${Font}, 默认用户密码: ${Sky_Blue}guest/guest_Api789${Font}"
        INFO "tvbox: ${Sky_Blue}http://ip:5678/tvbox/my_ext.json${Font}"
    else
        ERROR "安装失败！"
    fi

}

function update_xiaoya_alist() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅Alist${Blue} $i ${Font}\r"
        sleep 1
    done
    cat > "/tmp/container_update_xiaoya_alist_run.sh" <<- EOF
#!/bin/bash
if ! grep -q '2347' "/tmp/container_update_$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"; then
    sed -i '2s/^/-p 2347:2347 /' "/tmp/container_update_$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
fi
EOF
    container_update_extra_command="bash /tmp/container_update_xiaoya_alist_run.sh"
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    rm -f /tmp/container_update_xiaoya_alist_run.sh

}

function uninstall_xiaoya_alist() {

    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Alist${Blue} $i ${Font}\r"
        sleep 1
    done
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)")"
    VOLUMES="$(docker inspect -f '{{range .Mounts}}{{if eq .Type "volume"}}{{println .}}{{end}}{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | cut -d' ' -f2 | awk 'NF' | tr '\n' ' ')"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    docker rmi "${IMAGE_NAME}"
    docker volume rm ${VOLUMES}
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            for file in "${OLD_CONFIG_DIR}/mycheckintoken.txt" "${OLD_CONFIG_DIR}/mycmd.txt" "${OLD_CONFIG_DIR}/myruntime.txt"; do
                if [ -f "$file" ]; then
                    mv -f "$file" "/tmp/$(basename "$file")"
                fi
            done
            rm -rf \
                ${OLD_CONFIG_DIR}/*.txt* \
                ${OLD_CONFIG_DIR}/*.m3u* \
                ${OLD_CONFIG_DIR}/*.m3u8*
            if [ -d "${OLD_CONFIG_DIR}/xiaoya_backup" ]; then
                rm -rf ${OLD_CONFIG_DIR}/xiaoya_backup
            fi
            for file in /tmp/mycheckintoken.txt /tmp/mycmd.txt /tmp/myruntime.txt; do
                if [ -f "$file" ]; then
                    mv -f "$file" "${OLD_CONFIG_DIR}/$(basename "$file")"
                fi
            done
        fi
    fi
    INFO "小雅Alist卸载成功！"
}

function judgment_xiaoya_alist_sync_data_status() {

    if command -v crontab > /dev/null 2>&1; then
        if crontab -l | grep 'xiaoya_data_downloader' > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        if grep 'xiaoya_data_downloader' /etc/crontab > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    else
        echo -e "${Red}未知${Font}"
    fi

}

function uninstall_xiaoya_alist_sync_data() {

    if command -v crontab > /dev/null 2>&1; then
        crontab -l > /tmp/cronjob.tmp
        sedsh '/xiaoya_data_downloader/d' /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        rm -f /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        sedsh '/xiaoya_data_downloader/d' /etc/crontab
    fi

}

function main_xiaoya_alist() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "4、创建/删除 定时同步更新数据（${Red}功能已弃用，只提供删除${Font}）  当前状态：$(judgment_xiaoya_alist_sync_data_status)"
    echo -e "5、账号管理"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-5]:" num
    case "$num" in
    1)
        clear
        get_config_dir
        SET_NET_MODE=true
        install_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    2)
        clear
        update_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    3)
        clear
        uninstall_xiaoya_alist
        return_menu "main_xiaoya_alist"
        ;;
    4)
        clear
        if command -v crontab > /dev/null 2>&1; then
            if crontab -l | grep xiaoya_data_downloader > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_alist_sync_data
                clear
                INFO "已删除"
            else
                INFO "功能已弃用，目前只提供删除！"
            fi
        elif [ -f /etc/synoinfo.conf ]; then
            if grep 'xiaoya_data_downloader' /etc/crontab > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_alist_sync_data
                clear
                INFO "已删除"
            else
                INFO "功能已弃用，目前只提供删除！"
            fi
        else
            INFO "功能已弃用，目前只提供删除！"
        fi
        return_menu "main_xiaoya_alist"
        ;;
    5)
        clear
        main_account_management
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-5]'
        main_xiaoya_alist
        ;;
    esac

}

function get_docker0_url() {

    if command -v ifconfig > /dev/null 2>&1; then
        docker0=$(ifconfig docker0 | awk '/inet / {print $2}' | sed 's/addr://')
    else
        docker0=$(ip addr show docker0 | awk '/inet / {print $2}' | cut -d '/' -f 1)
    fi

    if [ -n "$docker0" ]; then
        INFO "docker0 的 IP 地址是：$docker0"
    else
        WARN "无法获取 docker0 的 IP 地址！"
        if [[ "${OSNAME}" = "macos" ]]; then
            docker0=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
        else
            docker0=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
        fi
        INFO "尝试使用本地IP：${docker0}"
    fi

}

function test_xiaoya_status() {

    get_docker0_url

    INFO "测试xiaoya的联通性..."
    if curl -siL -m 10 http://127.0.0.1:5678/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id"; then
        xiaoya_addr="http://127.0.0.1:5678"
    elif curl -siL -m 10 http://${docker0}:5678/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id"; then
        xiaoya_addr="http://${docker0}:5678"
    else
        if [ -s ${CONFIG_DIR}/docker_address.txt ]; then
            docker_address=$(head -n1 ${CONFIG_DIR}/docker_address.txt)
            if curl -siL -m 10 ${docker_address}/d/README.md | grep -v 302 | grep -e "x-oss-" -e "x-115-request-id"; then
                xiaoya_addr=${docker_address}
            else
                __xiaoya_connectivity_detection=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt)
                if [ "${__xiaoya_connectivity_detection}" == "false" ]; then
                    xiaoya_addr=${docker_address}
                    WARN "您已设置跳过小雅连通性检测"
                else
                    ERROR "请检查xiaoya是否正常运行后再试"
                    ERROR "小雅日志如下："
                    docker logs --tail 8 "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
                    exit 1
                fi
            fi
        else
            ERROR "请先配置 ${CONFIG_DIR}/docker_address.txt 后重试"
            exit 1
        fi
    fi

    INFO "连接小雅地址为 ${xiaoya_addr}"

}

function test_disk_capacity() {

    if [ ! -d "${MEDIA_DIR}" ]; then
        mkdir -p "${MEDIA_DIR}"
    fi

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))

    __disk_capacity_detection=$(cat ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt)
    if [ "${__disk_capacity_detection}" == "false" ]; then
        WARN "您已设置跳过磁盘容量检测"
        INFO "磁盘容量：${free_size_G}G"
    else
        if [ "$free_size" -le 230686720 ]; then
            ERROR "空间剩余容量不够：${free_size_G}G 小于最低要求 220G"
            exit 1
        else
            INFO "磁盘容量：${free_size_G}G"
        fi
    fi

}

function pull_run_glue() {

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            docker_pull "xiaoyaliu/glue:latest"
        fi
    else
        docker_pull "xiaoyaliu/glue:latest"
    fi

    if [ -n "${extra_parameters}" ]; then
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            ${extra_parameters} \
            -e LANG=C.UTF-8 \
            -e TZ=Asia/Shanghai \
            xiaoyaliu/glue:latest \
            "${@}"
    else
        docker run -it \
            --security-opt seccomp=unconfined \
            --rm \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            -e LANG=C.UTF-8 \
            -e TZ=Asia/Shanghai \
            xiaoyaliu/glue:latest \
            "${@}"
    fi

}

function pull_run_glue_xh() {

    BUILDER_NAME="xiaoya_builder_$(date +%S%N | cut -c 7-11)"

    if docker inspect xiaoyaliu/glue:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' xiaoyaliu/glue:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/xiaoyaliu/glue/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi xiaoyaliu/glue:latest
            docker_pull "xiaoyaliu/glue:latest"
        fi
    else
        docker_pull "xiaoyaliu/glue:latest"
    fi

    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            --security-opt seccomp=unconfined \
            --name=${BUILDER_NAME} \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            ${extra_parameters} \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}" > /dev/null 2>&1
    else
        docker run -itd \
            --security-opt seccomp=unconfined \
            --name=${BUILDER_NAME} \
            --net=host \
            -v "${MEDIA_DIR}:/media" \
            -v "${CONFIG_DIR}:/etc/xiaoya" \
            -e LANG=C.UTF-8 \
            xiaoyaliu/glue:latest \
            "${@}" > /dev/null 2>&1
    fi

    timeout=20
    start_time=$(date +%s)
    end_time=$((start_time + timeout))
    while [ "$(date +%s)" -lt $end_time ]; do
        status=$(docker inspect -f '{{.State.Status}}' "${BUILDER_NAME}")
        if [ "$status" = "exited" ]; then
            break
        fi
        sleep 1
    done

    status=$(docker inspect -f '{{.State.Status}}' "${BUILDER_NAME}")
    if [ "$status" != "exited" ]; then
        docker kill ${BUILDER_NAME} > /dev/null 2>&1
    fi
    docker rm ${BUILDER_NAME} > /dev/null 2>&1

}

function set_emby_server_infuse_api_key() {

    get_docker0_url

    echo "http://$docker0:6908" > "${CONFIG_DIR}"/emby_server.txt

    if [ ! -f "${CONFIG_DIR}"/infuse_api_key.txt ]; then
        echo "e825ed6f7f8f44ffa0563cddaddce14d" > "${CONFIG_DIR}"/infuse_api_key.txt
    fi

}

function check_metadata_size() {

    local file_size check_result

    file_size=$(du -k "${MEDIA_DIR}/temp/${1}" | cut -f1)

    case "${1}" in
    config.mp4)
        if [[ "$file_size" -le 3200000 ]]; then
            check_result=false
        fi
        ;;
    all.mp4)
        if [[ "$file_size" -le 30000000 ]]; then
            check_result=false
        fi
        ;;
    pikpak.mp4)
        if [[ "$file_size" -le 14000000 ]]; then
            check_result=false
        fi
        ;;
    115.mp4)
        if [[ "$file_size" -le 16000000 ]]; then
            check_result=false
        fi
        ;;
    config.new.mp4)
        if [[ "$file_size" -le 3200000 ]]; then
            check_result=false
        fi
        ;;
    esac

    if [ "${check_result}" == false ]; then
        ERROR "${1} 下载不完整，文件大小(in KB):$file_size 小于预期"
        return 1
    fi
    INFO "${1} 文件大小验证正常，文件大小(in KB):$file_size"
    return 0

}

function __unzip_all_metadata() {

    start_time1=$(date +%s)

    local files=("all.mp4" "config.mp4" "115.mp4" "pikpak.mp4")
    for file in "${files[@]}"; do
        if ! check_metadata_size "${file}"; then
            exit 1
        fi
        if [ "${file}" == "config.mp4" ]; then
            extra_parameters="--workdir=/media"
        else
            extra_parameters="--workdir=/media/xiaoya"
        fi
        pull_run_glue 7z x -aoa -mmt=16 "temp/${file}"
    done

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

}

function unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    rm -rf "${MEDIA_DIR}"/config

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}"/xiaoya
    mkdir -p "${MEDIA_DIR}"/config
    chmod 755 "${MEDIA_DIR}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown root "${MEDIA_DIR}"
    else
        chown root:root "${MEDIA_DIR}"
    fi

    INFO "开始解压..."

    __unzip_all_metadata

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    INFO "解压完成！"

}

function unzip_xiaoya_emby() {

    get_config_dir

    get_media_dir

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    chmod 777 "${MEDIA_DIR}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown root "${MEDIA_DIR}"
    else
        chown root:root "${MEDIA_DIR}"
    fi

    INFO "开始解压 ${MEDIA_DIR}/temp/${1} ..."

    if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，文件不完整！"
        exit 1
    fi

    start_time1=$(date +%s)

    if [ "${1}" == "config.mp4" ]; then
        extra_parameters="--workdir=/media"

        if [ -d "${MEDIA_DIR}/config" ]; then
            INFO "清理旧配置文件中..."
            INFO "这可能需要一定时间，请耐心等待！"
            rm -rf ${MEDIA_DIR}/config
        fi
        mkdir -p "${MEDIA_DIR}"/config
        chmod -R 777 "${MEDIA_DIR}"/config

        if ! check_metadata_size "config.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 temp/config.mp4

        INFO "设置目录权限..."
        INFO "这可能需要一定时间，请耐心等待！"
        chmod -R 777 "${MEDIA_DIR}"/config
    elif [ "${1}" == "all.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        if ! check_metadata_size "all.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 /media/temp/all.mp4

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "pikpak.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        if ! check_metadata_size "pikpak.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 /media/temp/pikpak.mp4

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "115.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        if ! check_metadata_size "115.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 /media/temp/115.mp4

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    fi

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "解压完成！"

}

function unzip_appoint_xiaoya_emby_jellyfin() {

    get_config_dir

    get_media_dir

    if [ "${1}" == "all.mp4" ] || [ "${1}" == "all_jf.mp4" ]; then
        INFO "请选择要解压的压缩包目录 [ 1:动漫 | 2:每日更新 | 3:电影 | 4:电视剧 | 5:纪录片 | 6:纪录片（已刮削）| 7:综艺 ]"
        valid_choice=false
        while [ "$valid_choice" = false ]; do
            read -erp "请输入数字 [1-7]:" choice
            for i in {1..7}; do
                if [ "$choice" = "$i" ]; then
                    valid_choice=true
                    break
                fi
            done
            if [ "$valid_choice" = false ]; then
                ERROR "请输入正确数字 [1-7]"
            fi
        done
        case $choice in
        1)
            UNZIP_FOLD=动漫
            ;;
        2)
            UNZIP_FOLD=每日更新
            ;;
        3)
            UNZIP_FOLD=电影
            ;;
        4)
            UNZIP_FOLD=电视剧
            ;;
        5)
            UNZIP_FOLD=纪录片
            ;;
        6)
            UNZIP_FOLD=纪录片（已刮削）
            ;;
        7)
            UNZIP_FOLD=综艺
            ;;
        esac
    elif [ "${1}" == "115.mp4" ]; then
        INFO "请选择要解压的压缩包目录 [ 1:电视剧 | 2:电影 | 3:动漫 ]"
        valid_choice=false
        while [ "$valid_choice" = false ]; do
            read -erp "请输入数字 [1-3]:" choice
            for i in {1..3}; do
                if [ "$choice" = "$i" ]; then
                    valid_choice=true
                    break
                fi
            done
            if [ "$valid_choice" = false ]; then
                ERROR "请输入正确数字 [1-3]"
            fi
        done
        case $choice in
        1)
            UNZIP_FOLD=电视剧
            ;;
        2)
            UNZIP_FOLD=电影
            ;;
        3)
            UNZIP_FOLD=动漫
            ;;
        esac
    else
        ERROR "此文件暂时不支持解压指定元数据！"
    fi

    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    chmod 777 "${MEDIA_DIR}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown root "${MEDIA_DIR}"
    else
        chown root:root "${MEDIA_DIR}"
    fi

    INFO "开始解压 ${MEDIA_DIR}/temp/${1} ${UNZIP_FOLD} ..."

    if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
        ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，文件不完整！"
        exit 1
    fi

    start_time1=$(date +%s)

    if [ "${1}" == "all.mp4" ] || [ "${1}" == "all_jf.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya

        if ! check_metadata_size "all.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 /media/temp/${1} ${UNZIP_FOLD}/* -o/media/xiaoya

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    elif [ "${1}" == "115.mp4" ]; then
        extra_parameters="--workdir=/media/xiaoya"

        mkdir -p "${MEDIA_DIR}"/xiaoya/115

        if ! check_metadata_size "115.mp4"; then
            exit 1
        fi
        pull_run_glue 7z x -aoa -mmt=16 /media/temp/${1} 115/${UNZIP_FOLD}/* -o/media/xiaoya

        INFO "设置目录权限..."
        chmod 777 "${MEDIA_DIR}"/xiaoya
    else
        ERROR "此文件暂时不支持解压指定元数据！"
    fi

    end_time1=$(date +%s)
    total_time1=$((end_time1 - start_time1))
    total_time1=$((total_time1 / 60))
    INFO "解压执行时间：$total_time1 分钟"

    INFO "解压完成！"

}

function download_xiaoya_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    if [[ "${OSNAME}" = "macos" ]]; then
        chown 0 "${MEDIA_DIR}"/temp
    else
        chown 0:0 "${MEDIA_DIR}"/temp
    fi
    chmod 777 "${MEDIA_DIR}"/temp
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    if [ -f "${MEDIA_DIR}/temp/${1}" ]; then
        INFO "清理旧 ${1} 中..."
        rm -f ${MEDIA_DIR}/temp/${1}
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            rm -rf ${MEDIA_DIR}/temp/${1}.aria2
        fi
    fi

    INFO "开始下载 ${1} ..."
    INFO "下载路径：${MEDIA_DIR}/temp/${1}"

    extra_parameters="--workdir=/media/temp"

    if pull_run_glue aria2c -o "${1}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/${1}"; then
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            ERROR "存在 ${MEDIA_DIR}/temp/${1}.aria2 文件，下载不完整！"
            exit 1
        else
            INFO "${1} 下载成功！"
        fi
    else
        ERROR "${1} 下载失败！"
        exit 1
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown 0 "${MEDIA_DIR}"/temp/"${1}"
    else
        chown 0:0 "${MEDIA_DIR}"/temp/"${1}"
    fi

    INFO "下载完成！"

}

function download_wget_xiaoya_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}"/temp
    if [[ "${OSNAME}" = "macos" ]]; then
        chown 0 "${MEDIA_DIR}"/temp
    else
        chown 0:0 "${MEDIA_DIR}"/temp
    fi
    chmod 777 "${MEDIA_DIR}"/temp
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    INFO "磁盘容量：${free_size_G}G"

    if [ -f "${MEDIA_DIR}/temp/${1}" ]; then
        INFO "清理旧 ${1} 中..."
        rm -f ${MEDIA_DIR}/temp/${1}
        if [ -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            rm -rf ${MEDIA_DIR}/temp/${1}.aria2
        fi
    fi

    INFO "开始下载 ${1} ..."
    INFO "下载路径：${MEDIA_DIR}/temp/${1}"

    extra_parameters="--workdir=/media/temp"

    if ! pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/${1}"; then
        ERROR "${1} 下载失败！"
        exit 1
    fi

    INFO "设置目录权限..."
    chmod 777 "${MEDIA_DIR}"/temp/"${1}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown 0 "${MEDIA_DIR}"/temp/"${1}"
    else
        chown 0:0 "${MEDIA_DIR}"/temp/"${1}"
    fi

    INFO "下载完成！"

}

function download_unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    rm -rf "${MEDIA_DIR}/config"

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/config"
    chmod 755 "${MEDIA_DIR}"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown root "${MEDIA_DIR}"
    else
        chown root:root "${MEDIA_DIR}"
    fi

    INFO "开始下载解压..."

    local files=("all.mp4" "config.mp4" "115.mp4" "pikpak.mp4")
    for file in "${files[@]}"; do
        extra_parameters="--workdir=/media/temp"
        if ! pull_run_glue aria2c -o "${file}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/${file}"; then
            ERROR "${file} 下载失败！"
            exit 1
        fi
    done

    __unzip_all_metadata

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    INFO "下载解压完成！"

}

function download_wget_unzip_xiaoya_all_emby() {

    get_config_dir

    get_media_dir

    test_xiaoya_status

    mkdir -p "${MEDIA_DIR}/temp"
    rm -rf "${MEDIA_DIR}/config"

    test_disk_capacity

    mkdir -p "${MEDIA_DIR}/xiaoya"
    mkdir -p "${MEDIA_DIR}/config"
    mkdir -p "${MEDIA_DIR}/temp"
    if [[ "${OSNAME}" = "macos" ]]; then
        chown 0 "${MEDIA_DIR}"
    else
        chown 0:0 "${MEDIA_DIR}"
    fi
    chmod 777 "${MEDIA_DIR}"

    local files=("all.mp4" "config.mp4" "115.mp4" "pikpak.mp4")
    for file in "${files[@]}"; do
        if [ -f "${MEDIA_DIR}/temp/${file}.aria2" ]; then
            rm -rf "${MEDIA_DIR}/temp/${file}.aria2"
        fi
    done

    INFO "开始下载解压..."

    for file in "${files[@]}"; do
        extra_parameters="--workdir=/media/temp"
        if ! pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/${file}"; then
            ERROR "${file} 下载失败！"
            exit 1
        fi
    done

    __unzip_all_metadata

    set_emby_server_infuse_api_key

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}"

    host=$(echo $xiaoya_addr | cut -f1,2 -d:)
    INFO "刮削数据已经下载解压完成，请登入${host}:2345，用户名:xiaoya   密码:1234"

}

function download_unzip_xiaoya_emby_new_config() {

    function compare_version() {

        if [ "${1}" == "4.8.9.0" ]; then
            return 0
        fi

        if [ "$(echo -e "${1}\n4.8.9.0" | sort -V | head -n1)" == "${1}" ]; then
            return 1
        else
            return 0
        fi

    }

    function compare_metadata_size() {

        local REMOTE_METADATA_SIZE LOCAL_METADATA_SIZE

        pull_run_glue_xh xh --headers --follow --timeout=10 -o /media/headers.log "${xiaoya_addr}/d/元数据/${1}"
        REMOTE_METADATA_SIZE=$(cat ${MEDIA_DIR}/headers.log | grep 'Content-Length' | awk '{print $2}')
        rm -f ${MEDIA_DIR}/headers.log

        if [ -f "${MEDIA_DIR}/temp/${1}" ] && [ ! -f "${MEDIA_DIR}/temp/${1}.aria2" ]; then
            LOCAL_METADATA_SIZE=$(du -b "${MEDIA_DIR}/temp/${1}" | awk '{print $1}')
        else
            LOCAL_METADATA_SIZE=0
        fi

        INFO "${1} REMOTE_METADATA_SIZE: ${REMOTE_METADATA_SIZE}"
        INFO "${1} LOCAL_METADATA_SIZE: ${LOCAL_METADATA_SIZE}"

        if
            [ "${REMOTE_METADATA_SIZE}" != "${LOCAL_METADATA_SIZE}" ] &&
                [ -n "${REMOTE_METADATA_SIZE}" ] &&
                awk -v remote="${REMOTE_METADATA_SIZE}" -v threshold="2147483648" 'BEGIN { if (remote > threshold) print "1"; else print "0"; }' | grep -q "1"
        then
            return 1
        else
            return 0
        fi

    }

    get_config_dir

    get_media_dir

    if [ -f "${MEDIA_DIR}/config/config/system.xml" ]; then
        INFO "检测到非第一次安装全家桶..."
        WARN "警告：本次元数据升级会丢失当前 Emby 所有用户配置信息！"
        local OPERATE
        while true; do
            INFO "是否继续操作 [Y/n]（默认 Y）"
            read -erp "OPERATE:" OPERATE
            [[ -z "${OPERATE}" ]] && OPERATE="y"
            if [[ ${OPERATE} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ "${OPERATE}" == [Nn] ]]; then
            exit 0
        fi

        local emby_name emby_image_name emby_version
        emby_name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
        emby_image_name="$(docker container inspect -f '{{.Config.Image}}' "${emby_name}")"
        if [ -z "${emby_image_name}" ]; then
            ERROR "获取 Emby 镜像标签失败，请确保您已安装 Emby！"
            exit 1
        fi
        if [ -f "${MEDIA_DIR}/EmbyServer.deps.json" ]; then
            rm -f "${MEDIA_DIR}/EmbyServer.deps.json"
        fi
        CURRENT_ULIMIT=$(ulimit -n)
        ulimit -n 65535
        docker run --rm --ulimit nofile=65535:65535 --entrypoint cp -v "${MEDIA_DIR}:/data" "${emby_image_name}" /system/EmbyServer.deps.json /data
        ulimit -n "${CURRENT_ULIMIT}"
        if [ ! -f "${MEDIA_DIR}/EmbyServer.deps.json" ]; then
            ERROR "Emby 版本数据文件复制失败！"
            exit 1
        fi
        emby_version=$(grep "EmbyServer" "${MEDIA_DIR}/EmbyServer.deps.json" | head -n 1 | sed -n 's|.*EmbyServer/\(.*\)":.*|\1|p')
        rm -f "${MEDIA_DIR}/EmbyServer.deps.json"
        if [ -n "${emby_version}" ]; then
            INFO "当前 Emby 版本：${emby_version}"
        else
            ERROR "当前 Emby 版本获取失败！"
            exit 1
        fi
        if ! compare_version "${emby_version}"; then
            INFO "您的 Emby 版本过低，开始进入升级流程，请升级到 4.8.9.0 或更高版本！"
            oneclick_upgrade_emby
        fi

        INFO "关闭 Emby 容器中..."
        if ! docker stop "${emby_name}"; then
            if ! docker kill "${emby_name}"; then
                ERROR "关闭 Emby 容器失败！"
                exit 1
            fi
        fi
    fi

    test_xiaoya_status

    INFO "清理旧配置文件中..."
    INFO "这可能需要一定时间，请耐心等待！"
    rm -rf "${MEDIA_DIR}/config"

    mkdir -p "${MEDIA_DIR}/config"
    chmod -R 777 "${MEDIA_DIR}"/config

    if [ -f "${MEDIA_DIR}/temp/config.new.mp4.aria2" ]; then
        rm -rf "${MEDIA_DIR}/temp/config.new.mp4.aria2"
        if [ -f "${MEDIA_DIR}/temp/config.new.mp4" ]; then
            INFO "清理不完整 config.new.mp4 中..."
            rm -rf "${MEDIA_DIR}/temp/config.new.mp4"
        fi
    fi
    if [ -f "${MEDIA_DIR}/temp/config.new.mp4" ]; then
        if compare_metadata_size "config.new.mp4"; then
            INFO "当前 config.new.mp4 已是最新，无需重新下载！"
        else
            INFO "清理旧 config.new.mp4 中..."
            rm -rf "${MEDIA_DIR}/temp/config.new.mp4"
        fi
    fi

    INFO "开始下载解压..."

    extra_parameters="--workdir=/media/temp"
    if [ "$(cat ${DDSREM_CONFIG_DIR}/data_downloader.txt)" == "wget" ]; then
        if ! pull_run_glue wget -c --show-progress "${xiaoya_addr}/d/元数据/config.new.mp4"; then
            ERROR "config.new.mp4 下载失败！"
            exit 1
        fi
    else
        if pull_run_glue aria2c -o "config.new.mp4" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${xiaoya_addr}/d/元数据/config.new.mp4"; then
            if [ -f "${MEDIA_DIR}/temp/config.new.mp4.aria2" ]; then
                ERROR "存在 ${MEDIA_DIR}/temp/config.new.mp4.aria2 文件，下载不完整！"
                exit 1
            else
                INFO "config.new.mp4 下载成功！"
            fi
        else
            ERROR "config.new.mp4 下载失败！"
            exit 1
        fi
    fi

    start_time1=$(date +%s)

    if ! check_metadata_size "config.new.mp4"; then
        exit 1
    fi
    extra_parameters="--workdir=/media"
    pull_run_glue 7z x -aoa -mmt=16 temp/config.new.mp4

    INFO "设置目录权限..."
    INFO "这可能需要一定时间，请耐心等待！"
    chmod -R 777 "${MEDIA_DIR}/config"

    docker start "${emby_name}"
    sleep 5
    wait_emby_start

    INFO "操作完成！"

}

function main_download_unzip_xiaoya_emby() {

    __data_downloader=$(cat ${DDSREM_CONFIG_DIR}/data_downloader.txt)

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}下载/解压 元数据${Font}\n"
    echo -e "1、下载并解压 全部元数据"
    echo -e "2、解压 全部元数据"
    echo -e "3、下载 all.mp4"
    echo -e "4、解压 all.mp4"
    echo -e "5、解压 all.mp4 的指定元数据目录【非全部解压】"
    echo -e "6、下载 config.mp4"
    echo -e "7、解压 config.mp4"
    echo -e "8、下载 pikpak.mp4"
    echo -e "9、解压 pikpak.mp4"
    echo -e "10、下载 115.mp4"
    echo -e "11、解压 115.mp4"
    echo -e "12、解压 115.mp4 的指定元数据目录【非全部解压】"
    echo -e "13、当前下载器【aria2/wget】                  当前状态：${Green}${__data_downloader}${Font}"
    echo -e "101、下载并解压 config.new.mp4"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字（支持输入多个数字，空格分离，按输入顺序执行）[0-13]:" -a nums
    for num in "${nums[@]}"; do
        if [ $num -ge 1 ] && [ $num -le 12 ]; then
            case "$num" in
            1)
                clear
                if [ "${__data_downloader}" == "wget" ]; then
                    download_wget_unzip_xiaoya_all_emby
                else
                    download_unzip_xiaoya_all_emby
                fi
                ;;
            2)
                clear
                unzip_xiaoya_all_emby
                ;;
            3)
                clear
                if [ "${__data_downloader}" == "wget" ]; then
                    download_wget_xiaoya_emby "all.mp4"
                else
                    download_xiaoya_emby "all.mp4"
                fi
                ;;
            4)
                clear
                unzip_xiaoya_emby "all.mp4"
                ;;
            5)
                clear
                unzip_appoint_xiaoya_emby_jellyfin "all.mp4"
                ;;
            6)
                clear
                if [ "${__data_downloader}" == "wget" ]; then
                    download_wget_xiaoya_emby "config.mp4"
                else
                    download_xiaoya_emby "config.mp4"
                fi
                ;;
            7)
                clear
                unzip_xiaoya_emby "config.mp4"
                ;;
            8)
                clear
                if [ "${__data_downloader}" == "wget" ]; then
                    download_wget_xiaoya_emby "pikpak.mp4"
                else
                    download_xiaoya_emby "pikpak.mp4"
                fi
                ;;
            9)
                clear
                unzip_xiaoya_emby "pikpak.mp4"
                ;;
            10)
                clear
                if [ "${__data_downloader}" == "wget" ]; then
                    download_wget_xiaoya_emby "115.mp4"
                else
                    download_xiaoya_emby "115.mp4"
                fi
                ;;
            11)
                clear
                unzip_xiaoya_emby "115.mp4"
                ;;
            12)
                clear
                unzip_appoint_xiaoya_emby_jellyfin "115.mp4"
                ;;
            esac
            __next_operate=return_menu
        elif [ $num == 101 ]; then
            clear
            download_unzip_xiaoya_emby_new_config
            __next_operate=return_menu
        elif [ $num == 13 ]; then
            if [ "${__data_downloader}" == "wget" ]; then
                echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
            elif [ "${__data_downloader}" == "aria2" ]; then
                echo 'wget' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
            else
                echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
            fi
            clear
            __next_operate=main_download_unzip_xiaoya_emby
            break
        elif [ $num == 0 ]; then
            clear
            __next_operate=main_xiaoya_all_emby
            break
        else
            clear
            ERROR '请输入正确数字 [0-13]'
            __next_operate=main_download_unzip_xiaoya_emby
            break
        fi
    done
    if [ "${__next_operate}" == "return_menu" ]; then
        return_menu "main_download_unzip_xiaoya_emby"
    elif [ "${__next_operate}" == "main_download_unzip_xiaoya_emby" ]; then
        main_download_unzip_xiaoya_emby
    elif [ "${__next_operate}" == "main_xiaoya_all_emby" ]; then
        main_xiaoya_all_emby
    fi

}

function install_emby_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        image_name="emby/embyserver"
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        image_name="emby/embyserver_arm64v8"
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac
    docker_pull "${image_name}:${IMAGE_VERSION}"
    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            --privileged=true \
            ${extra_parameters} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    else
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            --privileged=true \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    fi

}

function install_amilys_embyserver() {

    cpu_arch=$(uname -m)
    INFO "开始安装Emby容器....."
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        image_name="amilys/embyserver"
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        image_name="amilys/embyserver_arm64v8"
        ;;
    *)
        ERROR "目前只支持amd64和arm64架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac
    docker_pull "${image_name}:${IMAGE_VERSION}"
    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            ${extra_parameters} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    else
        docker run -itd \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            "${image_name}:${IMAGE_VERSION}"
    fi

}

function install_lovechen_embyserver() {

    INFO "开始安装Emby容器....."

    INFO "开始转换数据库..."

    mv ${MEDIA_DIR}/config/data/library.db ${MEDIA_DIR}/config/data/library.org.db
    if [ -f "${MEDIA_DIR}/config/data/library.db-wal" ]; then
        rm -rf ${MEDIA_DIR}/config/data/library.db-wal
    fi
    if [ -f "${MEDIA_DIR}/config/data/library.db-shm" ]; then
        rm -rf ${MEDIA_DIR}/config/data/library.db-shm
    fi
    chmod 777 ${MEDIA_DIR}/config/data/library.org.db
    curl -o ${MEDIA_DIR}/config/data/library.db https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/emby_lovechen/library.db
    curl -o ${MEDIA_DIR}/temp.sql https://cdn.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/emby_lovechen/temp.sql
    pull_run_glue sqlite3 /media/config/data/library.db ".read /media/temp.sql"

    INFO "数据库转换成功！"
    rm -rf ${MEDIA_DIR}/temp.sql

    docker_pull "lovechen/embyserver:${IMAGE_VERSION}"
    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            ${extra_parameters} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            lovechen/embyserver:${IMAGE_VERSION}
    else
        docker run -itd \
            --name "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)" \
            -v "${MEDIA_DIR}/config:/config" \
            -v "${MEDIA_DIR}/xiaoya:/media" \
            -v ${NSSWITCH}:/etc/nsswitch.conf \
            --add-host="xiaoya.host:$xiaoya_host" \
            ${NET_MODE} \
            -e UID=0 \
            -e GID=0 \
            -e TZ=Asia/Shanghai \
            --restart=always \
            lovechen/embyserver:${IMAGE_VERSION}
    fi

}

function choose_network_mode() {

    INFO "请选择使用的网络模式 [ 1:host | 2:bridge ]（默认 1）"
    read -erp "Net:" MODE
    [[ -z "${MODE}" ]] && MODE="1"
    if [[ ${MODE} == [1] ]]; then
        MODE=host
    elif [[ ${MODE} == [2] ]]; then
        MODE=bridge
    else
        ERROR "输入无效，请重新选择"
        choose_network_mode
    fi

    if [ "$MODE" == "host" ]; then
        NET_MODE="--net=host"
    elif [ "$MODE" == "bridge" ]; then
        NET_MODE="-p 6908:6908"
    fi

}

function choose_emby_image() {

    cpu_arch=$(uname -m)
    INFO "您的架构是：$cpu_arch"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver | 3:lovechen/embyserver(不推荐！目前不能直接同步config数据，且还存在一些已知问题未修复) ]（默认 2）"
        read -erp "IMAGE:" IMAGE
        [[ -z "${IMAGE}" ]] && IMAGE="2"
        if [[ ${IMAGE} == [1] ]]; then
            CHOOSE_EMBY=amilys_embyserver
        elif [[ ${IMAGE} == [2] ]]; then
            CHOOSE_EMBY=emby_embyserver
        elif [[ ${IMAGE} == [3] ]]; then
            CHOOSE_EMBY=lovechen_embyserver
        else
            ERROR "输入无效，请重新选择"
            choose_emby_image
        fi
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        INFO "请选择使用的Emby镜像 [ 1:amilys/embyserver | 2:emby/embyserver | 3:lovechen/embyserver(不推荐！目前不能直接同步config数据，且还存在一些已知问题未修复) ]（默认 2）"
        read -erp "IMAGE:" IMAGE
        [[ -z "${IMAGE}" ]] && IMAGE="2"
        if [[ ${IMAGE} == [1] ]]; then
            CHOOSE_EMBY=amilys_embyserver
        elif [[ ${IMAGE} == [2] ]]; then
            CHOOSE_EMBY=emby_embyserver
        elif [[ ${IMAGE} == [3] ]]; then
            CHOOSE_EMBY=lovechen_embyserver
        else
            ERROR "输入无效，请重新选择"
            choose_emby_image
        fi
        ;;
    *)
        ERROR "全家桶 Emby 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

}

function get_nsswitch_conf_path() {

    if [ -f /etc/nsswitch.conf ]; then
        NSSWITCH="/etc/nsswitch.conf"
    else
        CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ -d "${CONFIG_DIR}/nsswitch.conf" ]; then
            rm -rf ${CONFIG_DIR}/nsswitch.conf
        fi
        echo -e "hosts:\tfiles dns" > ${CONFIG_DIR}/nsswitch.conf
        echo -e "networks:\tfiles" >> ${CONFIG_DIR}/nsswitch.conf
        NSSWITCH="${CONFIG_DIR}/nsswitch.conf"
    fi
    INFO "nsswitch.conf 配置文件路径：${NSSWITCH}"

}

function get_xiaoya_hosts() { # 调用这个函数必须设置 $MODE 此变量

    if ! grep -q xiaoya.host ${HOSTS_FILE_PATH}; then
        if [ "$MODE" == "host" ]; then
            echo -e "127.0.0.1\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="127.0.0.1"
        elif [ "$MODE" == "bridge" ]; then
            echo -e "$docker0\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            xiaoya_host="$docker0"
        fi
    else
        if [ "$MODE" == "host" ]; then
            if grep -q "^${docker0}.*xiaoya\.host" ${HOSTS_FILE_PATH}; then
                sedsh '/xiaoya.host/d' ${HOSTS_FILE_PATH}
                echo -e "127.0.0.1\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            fi
        elif [ "$MODE" == "bridge" ]; then
            if grep -q "^127\.0\.0\.1.*xiaoya\.host" ${HOSTS_FILE_PATH}; then
                sedsh '/xiaoya.host/d' ${HOSTS_FILE_PATH}
                echo -e "$docker0\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
            fi
        fi
        xiaoya_host=$(grep xiaoya.host ${HOSTS_FILE_PATH} | awk '{print $1}' | head -n1)
    fi

    XIAOYA_HOSTS_SHOW=$(grep xiaoya.host ${HOSTS_FILE_PATH})
    # if echo "${XIAOYA_HOSTS_SHOW}" | awk '
    # {
    #     split($1, ip, ".");
    #     if(length(ip) == 4 && ip[1] >= 0 && ip[1] <= 255 && ip[2] >= 0 && ip[2] <= 255 && ip[3] >= 0 && ip[3] <= 255 && ip[4] >= 0 && ip[4] <= 255 && index($2, "\t") == 0)
    #         exit 0;
    #     else
    #         exit 1;
    # }'; then
    #     INFO "hosts 文件设置正确！"
    # else
    #     WARN "hosts 文件设置错误！"
    #     INFO "是否使用脚本自动纠错（只支持单机部署自动纠错，如果小雅和全家桶不在同一台机器上，请手动修改）[Y/n]（默认 Y）"
    #     read -erp "自动纠错:" FIX_HOST_ERROR
    #     [[ -z "${FIX_HOST_ERROR}" ]] && FIX_HOST_ERROR="y"
    #     if [[ ${FIX_HOST_ERROR} == [Yy] ]]; then
    #         INFO "开始自动纠错..."
    #         sedsh '/xiaoya\.host/d' /etc/hosts
    #         get_xiaoya_hosts
    #     else
    #         exit 1
    #     fi
    # fi
    if echo "${XIAOYA_HOSTS_SHOW}" | awk '{ if($1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $2 ~ /^[^\t]+$/) exit 0; else exit 1 }'; then
        INFO "hosts 文件格式设置正确！"
    else
        WARN "hosts 文件格式设置错误！"
        while true; do
            INFO "是否使用脚本自动纠错（只支持单机部署自动纠错，如果小雅和全家桶不在同一台机器上，请手动修改）[Y/n]（默认 Y）"
            read -erp "自动纠错:" FIX_HOST_ERROR
            [[ -z "${FIX_HOST_ERROR}" ]] && FIX_HOST_ERROR="y"
            if [[ ${FIX_HOST_ERROR} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${FIX_HOST_ERROR} == [Yy] ]]; then
            INFO "开始自动纠错..."
            sedsh '/xiaoya\.host/d' /etc/hosts
            get_xiaoya_hosts
        else
            exit 1
        fi
    fi

    INFO "${XIAOYA_HOSTS_SHOW}"

    response="$(curl -s -o /dev/null -w '%{http_code}' http://${xiaoya_host}:5678)"
    if [[ "$response" == "302" || "$response" == "200" ]]; then
        INFO "hosts 文件设置正确，本机可以正常访问小雅容器！"
    else
        response="$(curl -s -o /dev/null -w '%{http_code}' http://${xiaoya_host}:5678)"
        if [[ "$response" == "302" || "$response" == "200" ]]; then
            INFO "hosts 文件设置正确，本机可以正常访问小雅容器！"
        else
            if [[ "${OSNAME}" = "macos" ]]; then
                localip=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
            else
                if command -v ifconfig > /dev/null 2>&1; then
                    localip=$(ifconfig -a | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1)
                else
                    localip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
                fi
            fi
            INFO "尝试使用本机IP：${localip}"
            response="$(curl -s -o /dev/null -w '%{http_code}' http://${localip}:5678)"
            if [[ "$response" == "302" || "$response" == "200" ]]; then
                sedsh '/xiaoya.host/d' ${HOSTS_FILE_PATH}
                echo -e "$localip\txiaoya.host\n" >> ${HOSTS_FILE_PATH}
                INFO "hosts 文件设置成功，本机可以正常访问小雅容器！"
            else
                ERROR "hosts 文件设置错误，本机无法正常访问小雅容器！"
                exit 1
            fi
        fi
    fi

}

function install_emby_xiaoya_all_emby() {

    get_docker0_url

    if [ -f "${MEDIA_DIR}/config/config/system.xml" ]; then
        if ! grep -q 6908 ${MEDIA_DIR}/config/config/system.xml; then
            ERROR "Emby config 出错，请重新下载解压！"
            exit 1
        fi
    else
        if [ ! -f "${MEDIA_DIR}/temp/config.mp4" ]; then
            ERROR "config.mp4 不存在，请下载此文件并解压！"
        else
            ERROR "Emby config 出错，请重新下载解压！"
        fi
        exit 1
    fi

    if [ -f "${MEDIA_DIR}/config/data/device.txt" ]; then
        INFO "检测到存在 device.txt 文件！"
        if grep -q "1999bfd1661041cd85ff5e260bc04c06" ${MEDIA_DIR}/config/data/device.txt; then
            INFO "删除 device.txt 文件中..."
            rm -f ${MEDIA_DIR}/config/data/device.txt
        fi
    fi

    XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
    if [ -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
        # shellcheck disable=SC1091
        source "${XIAOYA_CONFIG_DIR}/emby_config.txt"

        if ! check_port "6908"; then
            ERROR "6908 端口被占用，请关闭占用此端口的程序！"
            exit 1
        fi

        # shellcheck disable=SC2154
        if [ "${mode}" == "bridge" ]; then
            MODE=bridge
            NET_MODE="-p 6908:6908"
        elif [ "${mode}" == "host" ]; then
            MODE=host
            NET_MODE="--net=host"
        else
            choose_network_mode
        fi

        get_xiaoya_hosts

        # shellcheck disable=SC2154
        if [ "${dev_dri}" == "yes" ]; then
            extra_parameters="--device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all"
        fi

        get_nsswitch_conf_path

        if [ -n "${version}" ]; then
            IMAGE_VERSION="${version}"
        else
            IMAGE_VERSION=4.8.9.0
        fi

        # shellcheck disable=SC2154
        if [ "${image}" == "emby" ]; then
            install_emby_embyserver
        else
            cpu_arch=$(uname -m)
            case $cpu_arch in
            "x86_64" | *"amd64"* | "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
                install_amilys_embyserver
                ;;
            *)
                ERROR "全家桶 Emby 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
                exit 1
                ;;
            esac
        fi

    else
        choose_emby_image

        if ! check_port "6908"; then
            ERROR "6908 端口被占用，请关闭占用此端口的程序！"
            exit 1
        fi

        choose_network_mode

        get_xiaoya_hosts

        INFO "如果需要开启Emby硬件转码请先返回主菜单开启容器运行额外参数添加 -> 72"
        container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
        if [ "${container_run_extra_parameters}" == "true" ]; then
            local RETURN_DATA
            RETURN_DATA="$(data_crep "r" "install_xiaoya_emby")"
            if [ "${RETURN_DATA}" == "None" ]; then
                INFO "请输入其他参数（默认 --device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all ）"
                read -erp "Extra parameters:" extra_parameters
                [[ -z "${extra_parameters}" ]] && extra_parameters="--device /dev/dri:/dev/dri --privileged -e GIDLIST=0,0 -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=all"
            else
                INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
                read -erp "Extra parameters:" extra_parameters
                [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
            fi
            extra_parameters=$(data_crep "write" "install_xiaoya_emby")
        fi

        get_nsswitch_conf_path

        while true; do
            case ${CHOOSE_EMBY} in
            "amilys_embyserver")
                cpu_arch=$(uname -m)
                if [[ $cpu_arch == "aarch64" || $cpu_arch == *"arm64"* || $cpu_arch == *"armv8"* || $cpu_arch == *"arm/v8"* ]]; then
                    WARN "amilys/embyserver_arm64v8 镜像无法指定版本号，默认拉取 latest 镜像！"
                    IMAGE_VERSION=latest
                    break
                else
                    INFO "请选择 Emby 镜像版本 [ 1；4.8.0.56 | 2；4.8.8.0 | 3；4.8.9.0 | 4；latest（${amilys_embyserver_latest_version}） ]（默认 3）"
                    read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
                    [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="3"
                    case ${CHOOSE_IMAGE_VERSION} in
                    1)
                        IMAGE_VERSION=4.8.0.56
                        break
                        ;;
                    2)
                        IMAGE_VERSION=4.8.8.0
                        break
                        ;;
                    3)
                        IMAGE_VERSION=4.8.9.0
                        break
                        ;;
                    4)
                        IMAGE_VERSION=latest
                        break
                        ;;
                    *)
                        ERROR "输入无效，请重新选择"
                        ;;
                    esac
                fi
                ;;
            "install_lovechen_embyserver")
                WARN "lovechen/embyserver 镜像无法指定版本号，默认拉取 4.7.14.0 镜像！"
                IMAGE_VERSION=4.7.14.0
                break
                ;;
            "emby_embyserver")
                INFO "请选择 Emby 镜像版本 [ 1；4.8.0.56 | 2；4.8.8.0 | 3；4.8.9.0 | 3；latest（${emby_embyserver_latest_version}） ]（默认 3）"
                read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
                [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="3"
                case ${CHOOSE_IMAGE_VERSION} in
                1)
                    IMAGE_VERSION=4.8.0.56
                    break
                    ;;
                2)
                    IMAGE_VERSION=4.8.8.0
                    break
                    ;;
                3)
                    IMAGE_VERSION=4.8.9.0
                    break
                    ;;
                4)
                    IMAGE_VERSION=latest
                    break
                    ;;
                *)
                    ERROR "输入无效，请重新选择"
                    ;;
                esac
                ;;
            esac
        done

        case ${CHOOSE_EMBY} in
        emby_embyserver)
            install_emby_embyserver
            ;;
        lovechen_embyserver)
            install_lovechen_embyserver
            ;;
        amilys_embyserver)
            install_amilys_embyserver
            ;;
        esac

    fi

    set_emby_server_infuse_api_key

    wait_emby_start

    sleep 2

    if ! curl -I -s http://$docker0:2345/ | grep -q "302"; then
        INFO "重启小雅容器中..."
        docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        wait_xiaoya_start
    fi

    INFO "Emby安装完成！"

}

function oneclick_upgrade_emby() {

    function check_emby_version() {

        if [ "${1}" == "${2}" ]; then
            return 0
        fi

        if [ "$(echo -e "${1}\n${2}" | sort -V | head -n1)" == "${1}" ]; then
            return 1
        else
            return 0
        fi

    }

    function get_emby_version() {

        local emby_name emby_image_name emby_config_dir CURRENT_ULIMIT
        emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
        emby_image_name="$(docker container inspect -f '{{.Config.Image}}' "${emby_name}")"
        emby_config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "${emby_name}" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/config$" | awk -F: '{print $1}')"
        if [ -z "${emby_image_name}" ]; then
            WARN "获取 Emby 镜像标签失败，请确保您已安装 Emby！"
            return 1
        fi
        if [ -z "${emby_config_dir}" ] || ! check_path "${emby_config_dir}"; then
            WARN "Emby 配置目录获取失败，使用 /tmp 目录替代！"
            emby_config_dir=/tmp
        fi
        if [ -f "${emby_config_dir}/EmbyServer.deps.json" ]; then
            rm -f "${emby_config_dir}/EmbyServer.deps.json"
        fi
        CURRENT_ULIMIT=$(ulimit -n)
        ulimit -n 65535
        docker run --rm --ulimit nofile=65535:65535 --entrypoint cp -v "${emby_config_dir}:/data" "${emby_image_name}" /system/EmbyServer.deps.json /data
        ulimit -n "${CURRENT_ULIMIT}"
        if [ ! -f "${emby_config_dir}/EmbyServer.deps.json" ]; then
            WARN "Emby 版本数据文件复制失败！"
            return 1
        fi
        emby_version=$(grep "EmbyServer" "${emby_config_dir}/EmbyServer.deps.json" | head -n 1 | sed -n 's|.*EmbyServer/\(.*\)":.*|\1|p')
        rm -f "${emby_config_dir}/EmbyServer.deps.json"
        if [ -z "${emby_version}" ]; then
            WARN "当前 Emby 版本获取失败！"
            return 1
        fi

    }

    local emby_name
    emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    if docker inspect ddsderek/runlike:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/runlike:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/ddsderek/runlike/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi ddsderek/runlike:latest
            docker_pull "ddsderek/runlike:latest"
        fi
    else
        docker_pull "ddsderek/runlike:latest"
    fi
    INFO "获取 ${emby_name} 容器信息中..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp ddsderek/runlike "${emby_name}" > "/tmp/container_update_${emby_name}"
    old_image=$(docker container inspect -f '{{.Config.Image}}' "${emby_name}")
    old_image_name="$(echo "${old_image}" | cut -d':' -f1)"
    INFO "获取 Emby 版本中..."
    if get_emby_version; then
        INFO "当前 Emby 版本：${emby_version}"
        check_emby_version_status=true
    else
        check_emby_version_status=false
    fi
    while true; do
        if [ "${old_image_name}" == "amilys/embyserver" ] || [ "${old_image_name}" == "amilys/embyserver_arm64v8" ]; then
            cpu_arch=$(uname -m)
            if [[ $cpu_arch == "aarch64" || $cpu_arch == *"arm64"* || $cpu_arch == *"armv8"* || $cpu_arch == *"arm/v8"* ]]; then
                WARN "amilys/embyserver_arm64v8 镜像无法指定版本号，默认重新拉取 latest 镜像更新容器！"
                IMAGE_VERSION=latest
                break
            else
                INFO "请选择 Emby 镜像版本 [ 1；4.8.8.0 | 2；4.8.9.0 | 3；latest（${amilys_embyserver_latest_version}）| 4；beta（${amilys_embyserver_beta_version}）（此版本请勿轻易尝试）]（默认 2）"
                read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
                [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="2"
                case ${CHOOSE_IMAGE_VERSION} in
                1)
                    IMAGE_VERSION=4.8.8.0
                    choose_emby_version="${IMAGE_VERSION}"
                    ;;
                2)
                    IMAGE_VERSION=4.8.9.0
                    choose_emby_version="${IMAGE_VERSION}"
                    ;;
                3)
                    IMAGE_VERSION=latest
                    choose_emby_version="${amilys_embyserver_latest_version}"
                    ;;
                4)
                    IMAGE_VERSION=beta
                    choose_emby_version="${amilys_embyserver_beta_version}"
                    ;;
                *)
                    ERROR "输入无效，请重新选择"
                    check_emby_version_status=false
                    ;;
                esac
                if [ "${check_emby_version_status}" == true ]; then
                    if check_emby_version "${choose_emby_version}" "${emby_version}"; then
                        break
                    else
                        ERROR "您选择升级的 Emby 版本低于当前安装 Emby 版本，Emby 版本无法降级，请重新选择"
                    fi
                fi
            fi
        elif [ "${old_image_name}" == "lovechen/embyserver" ]; then
            WARN "lovechen/embyserver 镜像无法更新！"
            exit 0
        elif [ "${old_image_name}" == "emby/embyserver" ] || [ "${old_image_name}" == "emby/embyserver_arm64v8" ]; then
            INFO "请选择 Emby 镜像版本 [ 1；4.8.8.0 | 2；4.8.9.0 | 3；latest（${emby_embyserver_latest_version}） | 4；beta（${emby_embyserver_beta_version}）（此版本请勿轻易尝试） ]（默认 2）"
            read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
            [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="2"
            case ${CHOOSE_IMAGE_VERSION} in
            1)
                IMAGE_VERSION=4.8.8.0
                choose_emby_version="${IMAGE_VERSION}"
                ;;
            2)
                IMAGE_VERSION=4.8.9.0
                choose_emby_version="${IMAGE_VERSION}"
                ;;
            3)
                IMAGE_VERSION=latest
                choose_emby_version="${emby_embyserver_latest_version}"
                ;;
            4)
                IMAGE_VERSION=beta
                choose_emby_version="${emby_embyserver_beta_version}"
                ;;
            *)
                ERROR "输入无效，请重新选择"
                check_emby_version_status=false
                ;;
            esac
            if [ "${check_emby_version_status}" == true ]; then
                if check_emby_version "${choose_emby_version}" "${emby_version}"; then
                    break
                else
                    ERROR "您选择升级的 Emby 版本低于当前安装 Emby 版本，Emby 版本无法降级，请重新选择"
                fi
            fi
        fi
    done
    run_image="$(echo "${old_image}" | cut -d':' -f1):${IMAGE_VERSION}"
    remove_image=$(docker images -q ${old_image})
    sedsh "s|${old_image}|${run_image}|g" "/tmp/container_update_${emby_name}"
    INFO "${old_image} ${old_image_name} ${run_image} ${remove_image}"
    local retries=0
    local max_retries=3
    IMAGE_MIRROR=$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")
    while [ $retries -lt $max_retries ]; do
        if docker pull "${IMAGE_MIRROR}/${run_image}"; then
            INFO "${emby_name} 镜像拉取成功！"
            break
        else
            WARN "${emby_name} 镜像拉取失败，正在进行第 $((retries + 1)) 次重试..."
            retries=$((retries + 1))
        fi
    done
    if [ $retries -eq $max_retries ]; then
        ERROR "镜像拉取失败，已达到最大重试次数！"
        exit 1
    else
        if [ "${IMAGE_MIRROR}" != "docker.io" ]; then
            pull_image=$(docker images -q "${IMAGE_MIRROR}/${run_image}")
        else
            pull_image=$(docker images -q "${run_image}")
        fi
        if ! docker stop "${emby_name}" > /dev/null 2>&1; then
            if ! docker kill "${emby_name}" > /dev/null 2>&1; then
                docker rmi "${IMAGE_MIRROR}/${run_image}"
                ERROR "更新失败，停止 ${emby_name} 容器失败！"
                exit 1
            fi
        fi
        INFO "停止 ${emby_name} 容器成功！"
        if ! docker rm --force "${emby_name}" > /dev/null 2>&1; then
            ERROR "更新失败，删除 ${emby_name} 容器失败！"
            exit 1
        fi
        INFO "删除 ${emby_name} 容器成功！"
        if [ "${pull_image}" != "${remove_image}" ]; then
            INFO "删除 ${remove_image} 镜像中..."
            docker rmi "${remove_image}" > /dev/null 2>&1
        fi
        if [ "${IMAGE_MIRROR}" != "docker.io" ]; then
            docker tag "${IMAGE_MIRROR}/${run_image}" "${run_image}" > /dev/null 2>&1
            docker rmi "${IMAGE_MIRROR}/${run_image}" > /dev/null 2>&1
        fi
        if bash "/tmp/container_update_${emby_name}"; then
            rm -f "/tmp/container_update_${emby_name}"
            wait_emby_start
            INFO "${emby_name} 更新成功"
            return 0
        else
            ERROR "更新失败，创建 ${emby_name} 容器失败！"
            exit 1
        fi
    fi

}

function install_xiaoya_notify_cron() {

    if [ ! -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        INFO "请输入Resilio-Sync配置文件目录"
        WARN "注意：Resilio-Sync 并且必须安装，本次获取目录只用于存放日志文件！"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        touch ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    fi
    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
        get_config_dir
    fi
    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
        get_media_dir
    fi

    # 配置定时任务Cron
    while true; do
        INFO "请输入您希望的同步时间"
        read -erp "注意：24小时制，格式：hh:mm，小时分钟之间用英文冒号分隔 （示例：23:45，默认：06:00）：" sync_time
        [[ -z "${sync_time}" ]] && sync_time="06:00"
        read -erp "您希望几天同步一次？（单位：天）（默认：7）" sync_day
        [[ -z "${sync_day}" ]] && sync_day="7"
        # 中文冒号纠错
        time_value=${sync_time//：/:}
        # 提取小时位
        hour=${time_value%%:*}
        # 提取分钟位
        minu=${time_value#*:}
        if [[ "$hour" -ge 0 && "$hour" -le 23 && "$minu" -ge 0 && "$minu" -le 59 ]]; then
            break
        else
            ERROR "输入错误，请重新输入。小时必须为0-23的正整数，分钟必须为0-59的正整数。"
        fi
    done

    while true; do
        INFO "是否开启Emby config自动同步 [Y/n]（默认 Y 开启）"
        read -erp "Auto update config:" AUTO_UPDATE_CONFIG
        [[ -z "${AUTO_UPDATE_CONFIG}" ]] && AUTO_UPDATE_CONFIG="y"
        if [[ ${AUTO_UPDATE_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${AUTO_UPDATE_CONFIG} == [Yy] ]]; then
        auto_update_config=yes
    else
        auto_update_config=no
    fi

    while true; do
        INFO "是否开启自动同步 all pikpak 和 115 元数据 [Y/n]（默认 Y 开启）"
        read -erp "Auto update all & pikpak:" AUTO_UPDATE_ALL_PIKPAK
        [[ -z "${AUTO_UPDATE_ALL_PIKPAK}" ]] && AUTO_UPDATE_ALL_PIKPAK="y"
        if [[ ${AUTO_UPDATE_ALL_PIKPAK} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${AUTO_UPDATE_ALL_PIKPAK} == [Yy] ]]; then
        auto_update_all_pikpak=yes
    else
        auto_update_all_pikpak=no
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_notify_cron")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
        extra_parameters=$(data_crep "w" "install_xiaoya_notify_cron")
    fi

    # 组合定时任务命令
    CRON="${minu} ${hour} */${sync_day} * *   bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh)\" -s \
--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
${extra_parameters} >> \
$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)/cron.log 2>&1"
    if command -v crontab > /dev/null 2>&1; then
        crontab -l | grep -v sync_emby_config | grep -v xiaoya_notify > /tmp/cronjob.tmp
        echo -e "${CRON}" >> /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        INFO '已经添加下面的记录到crontab定时任务'
        INFO "${CRON}"
        rm -rf /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        # 群晖单独支持
        cp /etc/crontab /etc/crontab.bak
        INFO "已创建/etc/crontab.bak备份文件"
        sedsh '/sync_emby_config/d; /xiaoya_notify/d' /etc/crontab
        echo -e "${CRON}" >> /etc/crontab
        INFO '已经添加下面的记录到crontab定时任务'
        INFO "${CRON}"
    else
        INFO '已经添加下面的记录到crontab定时任务容器'
        INFO "${CRON}"
        docker_pull "ddsderek/xiaoya-cron:latest"
        CRON_PARAMETERS="--auto_update_all_pikpak=${auto_update_all_pikpak} \
--auto_update_config=${auto_update_config} \
--media_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt) \
--config_dir=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt) \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt) \
${extra_parameters}"
        docker run -itd \
            --name=xiaoya-cron \
            -e TZ=Asia/Shanghai \
            -e CRON="${minu} ${hour} */${sync_day} * *" \
            -e parameters="${CRON_PARAMETERS}" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt):/config" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt):$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)" \
            -v "$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt):$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)" \
            -v /tmp:/tmp \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            --net=host \
            --restart=always \
            ddsderek/xiaoya-cron:latest
    fi

}

function install_resilio() {

    get_media_dir

    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        INFO "已读取Resilio-Sync配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    else
        INFO "请输入配置文件目录（默认 ${MEDIA_DIR}/resilio ）"
        read -erp "CONFIG_DIR:" CONFIG_DIR
        [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="${MEDIA_DIR}/resilio"
        touch ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
        echo "${CONFIG_DIR}" > ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt
    fi

    INFO "请输入后台管理端口（默认 8888 ）"
    read -erp "HT_PORT:" HT_PORT
    [[ -z "${HT_PORT}" ]] && HT_PORT="8888"

    INFO "请输入同步端口（默认 55555 ）"
    read -erp "SYNC_PORT:" SYNC_PORT
    [[ -z "${SYNC_PORT}" ]] && SYNC_PORT="55555"

    INFO "resilio容器内存上限（单位：MB，默认：2048）"
    WARN "PS: 部分系统有可能不支持内存限制设置，请输入 n 取消此设置！"
    read -erp "mem_size:" mem_size
    [[ -z "${mem_size}" ]] && mem_size="2048"
    if [[ ${mem_size} == [Nn] ]]; then
        mem_set=
    else
        mem_set="-m ${mem_size}M"
    fi

    INFO "resilio日志文件大小上限（单位：MB；默认：2；设置为 0 则代表关闭日志；设置为 n 则代表取消此设置）"
    read -erp "log_size:" log_size
    [[ -z "${log_size}" ]] && log_size="2"

    if [ "${log_size}" == "0" ]; then
        log_opinion="--log-driver none"
    elif [[ ${log_size} == [Nn] ]]; then
        log_opinion=
    else
        log_opinion="--log-opt max-size=${log_size}m --log-opt max-file=1"
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_resilio")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
        extra_parameters=$(data_crep "w" "install_xiaoya_resilio")
    fi

    while true; do
        INFO "是否自动配置系统 inotify watches & instances 的数值 [Y/n]（默认 Y）"
        read -erp "inotify:" inotify_set
        [[ -z "${inotify_set}" ]] && inotify_set="y"
        if [[ ${inotify_set} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${inotify_set} == [Yy] ]]; then
        if ! grep -q "fs.inotify.max_user_watches=524288" /etc/sysctl.conf; then
            echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf
        else
            INFO "系统 inotify watches 数值已存在！"
        fi
        if ! grep -q "fs.inotify.max_user_instances=524288" /etc/sysctl.conf; then
            echo fs.inotify.max_user_instances=524288 | tee -a /etc/sysctl.conf
        else
            INFO "系统 inotify instances 数值已存在！"
        fi
        # 清除多余的inotify设置
        awk \
            '!seen[$0]++ || !/^(fs\.inotify\.max_user_instances|fs\.inotify\.max_user_watches)/' /etc/sysctl.conf > \
            /tmp/sysctl.conf.tmp && mv /tmp/sysctl.conf.tmp /etc/sysctl.conf
        sysctl -p
        INFO "系统 inotify watches & instances 数值配置成功！"
    fi

    INFO "开始安装resilio..."
    if [ ! -d "${CONFIG_DIR}" ]; then
        mkdir -p "${CONFIG_DIR}"
    fi
    if [ ! -d "${CONFIG_DIR}/downloads" ]; then
        mkdir -p "${CONFIG_DIR}/downloads"
    fi
    docker_pull "linuxserver/resilio-sync:latest"
    if [ -n "${extra_parameters}" ]; then
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)" \
            ${mem_set} \
            ${log_opinion} \
            -e PUID=0 \
            -e PGID=0 \
            -e TZ=Asia/Shanghai \
            -p ${HT_PORT}:8888 \
            -p ${SYNC_PORT}:${SYNC_PORT} \
            -v "${CONFIG_DIR}:/config" \
            -v "${CONFIG_DIR}/downloads:/downloads" \
            -v "${MEDIA_DIR}:/sync" \
            ${extra_parameters} \
            --restart=always \
            linuxserver/resilio-sync:latest
    else
        docker run -d \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)" \
            ${mem_set} \
            ${log_opinion} \
            -e PUID=0 \
            -e PGID=0 \
            -e TZ=Asia/Shanghai \
            -p ${HT_PORT}:8888 \
            -p ${SYNC_PORT}:${SYNC_PORT} \
            -v "${CONFIG_DIR}:/config" \
            -v "${CONFIG_DIR}/downloads:/downloads" \
            -v "${MEDIA_DIR}:/sync" \
            --restart=always \
            linuxserver/resilio-sync:latest
    fi

    if [ "${SYNC_PORT}" != "55555" ]; then
        start_time=$(date +%s)
        while true; do
            if [ -f "${CONFIG_DIR}/sync.conf" ]; then
                sedsh "/\"listening_port\"/c\    \"listening_port\": ${SYNC_PORT}," ${CONFIG_DIR}/sync.conf
                docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
                break
            fi
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
            if ((elapsed_time >= 300)); then
                break
            fi
            sleep 1
        done
    fi

    install_xiaoya_notify_cron

    INFO "安装完成！"
    INFO "请浏览器访问 ${Sky_Blue}http://IP:${HT_PORT}${Font} 进行 Resilio 设置并自行添加下面的同步密钥："
    echo -e "/每日更新/电视剧 （保存到 /sync/xiaoya/每日更新/电视剧 ）
${Sky_Blue}BHB7NOQ4IQKOWZPCLK7BIZXDGIOVRKBUL${Font}
/每日更新/电影 （保存到 /sync/xiaoya/每日更新/电影 ）
${Sky_Blue}BCFQAYSMIIDJBWJ6DB7JXLHBXUGYKEQ43${Font}
/电影/2023 （保存到 /sync/xiaoya/电影/2023 ）
${Sky_Blue}BGUXZBXWJG6J47XVU4HSNJEW4HRMZGOPL${Font}
/纪录片（已刮削） （保存到 /sync/xiaoya/纪录片（已刮削） ）
${Sky_Blue}BDBOMKR6WP7A4X55Z6BY7IA4HUQ3YO4BH${Font}
/音乐 （保存到 /sync/xiaoya/音乐 ）
${Sky_Blue}BHAYCNF5MJSGUF2RVO6XDA55X5PVBKDUB${Font}
/每日更新/动漫 （保存到 /sync/xiaoya/每日更新/动漫 ）
${Sky_Blue}BQEIV6B3DKPZWAFHO7V6QQJO2X3DOQSJ4${Font}
/每日更新/动漫剧场版 （保存到 /sync/xiaoya/每日更新/动漫剧场版 ）
${Sky_Blue}B42SOXBKLMRWHRZMCAIQZWNOBLUUH3HO3${Font}"

}

function update_resilio() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新Resilio-Sync${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"

}

function uninstall_xiaoya_notify_cron() {

    # 清理定时同步任务
    if command -v crontab > /dev/null 2>&1; then
        crontab -l > /tmp/cronjob.tmp
        sedsh '/sync_emby_config/d; /xiaoya_notify/d' /tmp/cronjob.tmp
        crontab /tmp/cronjob.tmp
        rm -f /tmp/cronjob.tmp
    elif [ -f /etc/synoinfo.conf ]; then
        sedsh '/sync_emby_config/d; /xiaoya_notify/d' /etc/crontab
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            docker stop xiaoya-cron
            docker rm xiaoya-cron
            docker rmi ddsderek/xiaoya-cron:latest
        fi
    fi

}

function unisntall_resilio() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Resilio-Sync${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)"
    docker rmi linuxserver/resilio-sync:latest
    if [ -f ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt ]; then
        OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/resilio_config_dir.txt)
        rm -rf "${OLD_CONFIG_DIR}"
    fi

    uninstall_xiaoya_notify_cron

    INFO "Resilio-Sync 卸载成功！"

}

function main_resilio() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Resilio-Sync${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_resilio
        return_menu "main_resilio"
        ;;
    2)
        clear
        update_resilio
        return_menu "main_resilio"
        ;;
    3)
        clear
        unisntall_resilio
        return_menu "main_resilio"
        ;;
    0)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_resilio
        ;;
    esac

}

function once_sync_emby_config() {

    if command -v crontab > /dev/null 2>&1; then
        COMMAND_1=$(crontab -l | grep 'xiaoya_notify' | sed 's/^.*-s//; s/>>.*$//' | sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g')
        if [[ $COMMAND_1 == *"--force_update_config"* ]]; then
            if [[ $COMMAND_1 == *"--force_update_config=no"* ]]; then
                COMMAND_1="${COMMAND_1/--force_update_config=no/--force_update_config=yes}"
            fi
        else
            COMMAND_1="$COMMAND_1 --force_update_config=yes"
        fi
        if [ -z "$COMMAND_1" ]; then
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        else
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s ${COMMAND_1}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        COMMAND_1=$(grep 'xiaoya_notify' /etc/crontab | sed 's/^.*-s//; s/>>.*$//' | sed 's/--auto_update_all_pikpak=yes/--auto_update_all_pikpak=no/g')
        if [[ $COMMAND_1 == *"--force_update_config"* ]]; then
            if [[ $COMMAND_1 == *"--force_update_config=no"* ]]; then
                COMMAND_1="${COMMAND_1/--force_update_config=no/--force_update_config=yes}"
            fi
        else
            COMMAND_1="$COMMAND_1 --force_update_config=yes"
        fi
        if [ -z "$COMMAND_1" ]; then
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        else
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s ${COMMAND_1}"
        fi
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            # 先更新 xiaoya-cron，再运行立刻同步
            container_update xiaoya-cron
            sleep 10
            COMMAND="docker exec -it xiaoya-cron bash /app/command.sh"
        else
            get_config_dir
            get_media_dir
            COMMAND="bash -c \"\$(curl -k https://ddsrem.com/xiaoya/xiaoya_notify.sh | head -n -2 && echo detection_config_update)\" -s \
--auto_update_all_pikpak=no \
--auto_update_config=yes \
--force_update_config=yes \
--media_dir=${MEDIA_DIR} \
--config_dir=${CONFIG_DIR} \
--emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt) \
--resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt) \
--xiaoya_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        fi
    fi
    echo -e "${COMMAND}" > /tmp/sync_command.sh
    echo -e "${COMMAND}"

    while true; do
        INFO "是否前台输出运行日志 [Y/n]（默认 Y）"
        read -erp "Log out:" LOG_OUT
        [[ -z "${LOG_OUT}" ]] && LOG_OUT="y"
        if [[ ${LOG_OUT} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始同步小雅Emby的config目录${Blue} $i ${Font}\r"
        sleep 1
    done

    echo > /tmp/sync_config.log
    # 后台运行
    bash /tmp/sync_command.sh > /tmp/sync_config.log 2>&1 &
    # 获取pid
    pid=$!
    if [[ ${LOG_OUT} == [Yy] ]]; then
        clear
        # 实时输出模式
        while ps ${pid} > /dev/null; do
            clear
            cat /tmp/sync_config.log
            sleep 4
        done
        sleep 2
        rm -f /tmp/sync_command.sh
    else
        # 后台运行模式
        clear
        INFO "Emby config同步后台运行中..."
        INFO "运行日志存于 /tmp/sync_config.log 文件内。"
        # 守护进程，最终清理运行产生的文件
        {
            while ps ${pid} > /dev/null; do sleep 4; done
            sleep 2
            rm -f /tmp/sync_command.sh
        } &
    fi

}

function judgment_xiaoya_notify_status() {

    if command -v crontab > /dev/null 2>&1; then
        if crontab -l | grep 'xiaoya_notify\|sync_emby_config' > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    elif [ -f /etc/synoinfo.conf ]; then
        if grep 'xiaoya_notify\|sync_emby_config' /etc/crontab > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    else
        if docker container inspect xiaoya-cron > /dev/null 2>&1; then
            echo -e "${Green}已创建${Font}"
        else
            echo -e "${Red}未创建${Font}"
        fi
    fi

}

function install_xiaoya_emd() {

    get_media_dir

    while true; do
        INFO "请输入您希望的爬虫同步间隔"
        WARN "循环时间必须大于12h，为了减轻服务器压力，请用户理解！"
        read -erp "请输入以小时为单位的正整数同步间隔时间（默认：12）：" sync_interval
        [[ -z "${sync_interval}" ]] && sync_interval="12"
        if [[ "$sync_interval" -ge 12 ]]; then
            break
        else
            ERROR "输入错误，请重新输入。同步间隔时间必须为12以上的正整数。"
        fi
    done
    cycle=$((sync_interval * 60 * 60))

    while true; do
        INFO "是否开启重启容器自动更新到最新程序 [Y/n]（默认 n 不开启）"
        WARN "需要拥有良好的上网环境才可以更新成功，要能访问 Github 和 Python PIP 库！"
        read -erp "RESTART_AUTO_UPDATE:" RESTART_AUTO_UPDATE
        [[ -z "${RESTART_AUTO_UPDATE}" ]] && RESTART_AUTO_UPDATE="n"
        if [[ ${RESTART_AUTO_UPDATE} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${RESTART_AUTO_UPDATE} == [Yy] ]]; then
        RESTART_AUTO_UPDATE=true
    else
        RESTART_AUTO_UPDATE=false
    fi

    while true; do
        INFO "请选择镜像版本 [ 1；latest | 2；beta ]（默认 1）"
        read -erp "CHOOSE_IMAGE_VERSION:" CHOOSE_IMAGE_VERSION
        [[ -z "${CHOOSE_IMAGE_VERSION}" ]] && CHOOSE_IMAGE_VERSION="1"
        case ${CHOOSE_IMAGE_VERSION} in
        1)
            IMAGE_VERSION=latest
            break
            ;;
        2)
            IMAGE_VERSION=beta
            break
            ;;
        *)
            ERROR "输入无效，请重新选择"
            ;;
        esac
    done

    extra_parameters=
    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_emd")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入运行参数（默认 --media /media ）"
            WARN "如果需要更改此设置请注意容器目录映射，默认媒体库路径映射到容器内的 /media 文件夹下！"
            WARN "警告！！！ 默认请勿修改 /media 路径！！！"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters="--media /media"
        else
            INFO "已读取您上次设置的运行参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            WARN "如果需要更改此设置请注意容器目录映射，默认媒体库路径映射到容器内的 /media 文件夹下！"
            WARN "警告！！！ 默认请勿修改 /media 路径！！！"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
    else
        extra_parameters="--media /media"
    fi
    script_extra_parameters="$(data_crep "write" "install_xiaoya_emd")"

    extra_parameters=
    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA_2
        RETURN_DATA_2="$(data_crep "r" "install_xiaoya_emd_2")"
        if [ "${RETURN_DATA_2}" == "None" ]; then
            INFO "请输入运行容器额外参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的运行容器额外参数：${RETURN_DATA_2} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA_2}
        fi
        run_extra_parameters=$(data_crep "w" "install_xiaoya_emd_2")
    fi

    docker_pull "ddsderek/xiaoya-emd:${IMAGE_VERSION}"

    docker run -d \
        --name=xiaoya-emd \
        --restart=always \
        --net=host \
        -v "${MEDIA_DIR}/xiaoya:/media" \
        -e "CYCLE=${cycle}" \
        -e "RESTART_AUTO_UPDATE=${RESTART_AUTO_UPDATE}" \
        -e TZ=Asia/Shanghai \
        ${run_extra_parameters} \
        ddsderek/xiaoya-emd:${IMAGE_VERSION} \
        ${script_extra_parameters}

    INFO "安装完成！"

}

function update_xiaoya_emd() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅元数据定时爬虫${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update xiaoya-emd

}

function unisntall_xiaoya_emd() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅元数据定时爬虫${Blue} $i ${Font}\r"
        sleep 1
    done

    docker stop xiaoya-emd
    docker rm xiaoya-emd
    docker rmi ddsderek/xiaoya-emd:latest

    INFO "小雅元数据定时爬虫卸载成功！"

}

function main_xiaoya_emd() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅元数据定时爬虫${Font}\n"
    echo -e "${Sky_Blue}小雅元数据定时爬虫由 https://github.com/Rik-F5 更新维护，在此表示感谢！"
    echo -e "具体详细配置参数请看项目README：https://github.com/Rik-F5/xiaoya_db${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    2)
        clear
        update_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    3)
        clear
        unisntall_xiaoya_emd
        return_menu "main_xiaoya_emd"
        ;;
    0)
        clear
        main_xiaoya_all_emby
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_emd
        ;;
    esac

}

function uninstall_xiaoya_all_emby() {

    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Emby全家桶${Blue} $i ${Font}\r"
        sleep 1
    done
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)")"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)"
    docker rmi "${IMAGE_NAME}"
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt ]; then
            OLD_MEDIA_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_media_dir.txt)
            rm -rf "${OLD_MEDIA_DIR}"
        fi
    fi

    unisntall_resilio

    INFO "全家桶卸载成功！"

}

function main_xiaoya_all_emby() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Emby全家桶${Font}\n"
    echo -e "${Red}注意：2024年3月16日后Emby config同步定时任务更换为同步定时更新任务${Font}"
    echo -e "${Red}用户需先执行一遍 菜单27 删除旧任务，再执行一遍 菜单27 创建新任务${Font}"
    if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
        local container_status
        container_status=$(docker inspect --format='{{.State.Status}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)")
        case "${container_status}" in
        "running")
            echo
            ;;
        *)
            echo -e "\n${Red}警告：您的小雅容器未正常启动，请先检查小雅容器后再安装全家桶${Font}\n"
            ;;
        esac
    else
        echo -e "${Red}\n警告：您未安装小雅容器，请先安装小雅容器后再安装全家桶${Font}\n"
    fi
    echo -ne "${INFO} 界面加载中...${Font}\r"
    echo -e "1、一键安装Emby全家桶
2、下载/解压 元数据
3、安装Emby（可选择版本）
4、替换DOCKER_ADDRESS（${Red}已弃用${Font}）
5、安装/更新/卸载 Resilio-Sync（${Red}已弃用${Font}）      当前状态：$(judgment_container "${xiaoya_resilio_name}")
6、立即同步小雅Emby config目录
7、创建/删除 同步定时更新任务                 当前状态：$(judgment_xiaoya_notify_status)
8、图形化编辑 emby_config.txt
9、安装/更新/卸载 小雅元数据定时爬虫          当前状态：$(judgment_container xiaoya-emd)
10、一键升级Emby容器（可选择镜像版本）
11、卸载Emby全家桶"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-11]:" num
    case "$num" in
    1)
        clear
        download_unzip_xiaoya_all_emby
        install_emby_xiaoya_all_emby
        XIAOYA_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
        if [ -s "${XIAOYA_CONFIG_DIR}/emby_config.txt" ]; then
            # shellcheck disable=SC1091
            source "${XIAOYA_CONFIG_DIR}/emby_config.txt"
            if [ -n "${resilio}" ]; then
                WARN "Resilio-Sync 已弃用，默认使用 小雅元数据定时爬虫"
            fi
        fi
        while true; do
            INFO "是否安装 小雅元数据定时爬虫 [Y/n]（默认 Y）"
            read -erp "INSTALL:" xiaoya_emd_install
            [[ -z "${xiaoya_emd_install}" ]] && xiaoya_emd_install="y"
            if [[ ${xiaoya_emd_install} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${xiaoya_emd_install} == [Yy] ]]; then
            install_xiaoya_emd
        fi
        INFO "Emby 全家桶安装完成！ "
        INFO "浏览器访问 Emby 服务：${Sky_Blue}http://ip:2345${Font}, 默认用户密码: ${Sky_Blue}xiaoya/1234${Font}"
        return_menu "main_xiaoya_all_emby"
        ;;
    2)
        clear
        main_download_unzip_xiaoya_emby
        ;;
    3)
        clear
        get_config_dir
        get_media_dir
        install_emby_xiaoya_all_emby
        return_menu "main_xiaoya_all_emby"
        ;;
    4)
        clear
        WARN "此功能已弃用！"
        return_menu "main_xiaoya_all_emby"
        ;;
    5)
        clear
        main_resilio
        ;;
    6)
        clear
        once_sync_emby_config
        ;;
    7)
        clear
        if command -v crontab > /dev/null 2>&1; then
            if crontab -l | grep xiaoya_notify > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        elif [ -f /etc/synoinfo.conf ]; then
            if grep 'xiaoya_notify' /etc/crontab > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        else
            if docker container inspect xiaoya-cron > /dev/null 2>&1; then
                for i in $(seq -w 3 -1 0); do
                    echo -en "即将删除Emby config同步定时任务${Blue} $i ${Font}\r"
                    sleep 1
                done
                uninstall_xiaoya_notify_cron
                clear
                INFO "已删除"
            else
                install_xiaoya_notify_cron
            fi
        fi
        return_menu "main_xiaoya_all_emby"
        ;;
    8)
        clear
        get_config_dir
        bash -c "$(curl -sLk https://ddsrem.com/xiaoya/emby_config_editor.sh)" -s ${CONFIG_DIR}
        main_xiaoya_all_emby
        ;;
    9)
        clear
        main_xiaoya_emd
        ;;
    10)
        clear
        oneclick_upgrade_emby
        return_menu "main_xiaoya_all_emby"
        ;;
    11)
        clear
        uninstall_xiaoya_all_emby
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-11]'
        main_xiaoya_all_emby
        ;;
    esac

}

function xiaoyahelper_install_check() {
    local URL="$1"
    if bash -c "$(curl --insecure -fsSL ${URL} | tail -n +2)" -s "${MODE}" ${TG_CHOOSE}; then
        if docker container inspect xiaoyakeeper > /dev/null 2>&1; then
            INFO "安装完成！"
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

function install_xiaoyahelper() {

    INFO "选择模式：[3/5]（默认 3）"
    INFO "模式3: 定时运行小雅转存清理并升级小雅镜像"
    INFO "模式5: 只要产生了播放缓存一分钟内立即清理。签到和定时升级同模式3"
    read -erp "MODE:" MODE
    [[ -z "${MODE}" ]] && MODE="3"

    while true; do
        INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
        read -erp "TG:" TG
        [[ -z "${TG}" ]] && TG="n"
        if [[ ${TG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${TG} == [Yy] ]]; then
        TG_CHOOSE="-tg"
    fi

    docker_pull "ddsderek/xiaoyakeeper:latest"

    XIAOYAHELPER_URL="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"
    if xiaoyahelper_install_check "${XIAOYAHELPER_URL}"; then
        return 0
    fi
    XIAOYAHELPER_URL="https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh"
    if xiaoyahelper_install_check "${XIAOYAHELPER_URL}"; then
        return 0
    fi
    ERROR "安装失败！"
    return 1

}

function once_xiaoyahelper() {

    while true; do
        INFO "是否使用Telegram通知 [Y/n]（默认 n 不使用）"
        read -erp "TG:" TG
        [[ -z "${TG}" ]] && TG="n"
        if [[ ${TG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done
    if [[ ${TG} == [Yy] ]]; then
        TG_CHOOSE="-tg"
    fi

    XIAOYAHELPER_URL="https://xiaoyahelper.ddsrem.com/aliyun_clear.sh"
    if bash -c "$(curl --insecure -fsSL ${XIAOYAHELPER_URL} | tail -n +2)" -s 1 ${TG_CHOOSE}; then
        INFO "运行完成！"
    else
        XIAOYAHELPER_URL="https://xiaoyahelper.zengge99.eu.org/aliyun_clear.sh"
        if bash -c "$(curl --insecure -fsSL ${XIAOYAHELPER_URL} | tail -n +2)" -s 1 ${TG_CHOOSE}; then
            INFO "运行完成！"
        else
            ERROR "运行失败！"
            exit 1
        fi
    fi
}

function uninstall_xiaoyahelper() {

    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅助手（xiaoyahelper）${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop xiaoyakeeper
    docker rm xiaoyakeeper
    docker rmi dockerproxy.com/library/alpine:3.18.2 > /dev/null 2>&1
    docker rmi alpine:3.18.2 > /dev/null 2>&1
    docker rmi ddsderek/xiaoyakeeper:latest

    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            for file in "${OLD_CONFIG_DIR}/mycheckintoken.txt" "${OLD_CONFIG_DIR}/mycmd.txt" "${OLD_CONFIG_DIR}/myruntime.txt"; do
                if [ -f "$file" ]; then
                    rm -f "$file"
                fi
            done
        fi
        rm -f ${OLD_CONFIG_DIR}/*json
    fi

    INFO "小雅助手（xiaoyahelper）卸载成功！"

}

function main_xiaoyahelper() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅助手（xiaoyahelper）${Font}\n"
    echo -e "1、安装/更新"
    echo -e "2、一次性运行"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoyahelper
        return_menu "main_xiaoyahelper"
        ;;
    2)
        clear
        once_xiaoyahelper
        ;;
    3)
        clear
        uninstall_xiaoyahelper
        return_menu "main_xiaoyahelper"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoyahelper
        ;;
    esac

}

function install_xiaoya_alist_tvbox() {

    local DEFAULT_CONFIG_DIR
    while true; do
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
            INFO "已读取小雅Alist-TVBox配置文件路径：${OLD_CONFIG_DIR} (默认不更改回车继续，如果需要更改请输入新路径)"
            read -erp "CONFIG_DIR:" CONFIG_DIR
            [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR=${OLD_CONFIG_DIR}
        else
            DEFAULT_CONFIG_DIR="$(get_path "xiaoya_alist_config_dir")"
            INFO "请输入配置文件目录（默认 ${DEFAULT_CONFIG_DIR} ）"
            read -erp "CONFIG_DIR:" CONFIG_DIR
            [[ -z "${CONFIG_DIR}" ]] && CONFIG_DIR="${DEFAULT_CONFIG_DIR}"
            touch ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt
        fi
        if check_path "${CONFIG_DIR}"; then
            echo "${CONFIG_DIR}" > "${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt"
            INFO "目录合法性检测通过！"
            break
        else
            ERROR "非合法目录，请重新输入！"
        fi
    done

    while true; do
        INFO "请输入Alist端口（默认 5344 ）"
        read -erp "ALIST_PORT:" ALIST_PORT
        [[ -z "${ALIST_PORT}" ]] && ALIST_PORT="5344"
        if check_port "${ALIST_PORT}"; then
            break
        else
            ERROR "${ALIST_PORT} 此端口被占用，请输入其他端口！"
        fi
    done

    while true; do
        INFO "请输入后台管理端口（默认 4567 ）"
        read -erp "HT_PORT:" HT_PORT
        [[ -z "${HT_PORT}" ]] && HT_PORT="4567"
        if check_port "${HT_PORT}"; then
            break
        else
            ERROR "${HT_PORT} 此端口被占用，请输入其他端口！"
        fi
    done

    INFO "请输入内存限制（默认 -Xmx512M ）"
    read -erp "MEM_OPT:" MEM_OPT
    [[ -z "${MEM_OPT}" ]] && MEM_OPT="-Xmx512M"

    cpu_arch=$(uname -m)
    INFO "您的CPU架构：${cpu_arch}"
    case $cpu_arch in
    "x86_64" | *"amd64"*)
        while true; do
            INFO "是否使用内存优化版镜像 [Y/n]（默认 n 不使用）"
            read -erp "Native:" choose_native
            [[ -z "${choose_native}" ]] && choose_native="n"
            if [[ ${choose_native} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${choose_native} == [Yy] ]]; then
            __choose_native="native"
        else
            __choose_native="latest"
        fi
        ;;
    "aarch64" | *"arm64"* | *"armv8"* | *"arm/v8"*)
        __choose_native="latest"
        ;;
    *)
        ERROR "Xiaoya-TVBox 目前只支持 amd64 和 arm64 架构，你的架构是：$cpu_arch"
        exit 1
        ;;
    esac

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_alist_tvbox")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
        extra_parameters=$(data_crep "w" "install_xiaoya_alist_tvbox")
    fi

    if ls ${CONFIG_DIR}/*.txt 1> /dev/null 2>&1; then
        INFO "备份小雅配置数据中..."
        mkdir -p ${CONFIG_DIR}/xiaoya_backup
        cp -rf ${CONFIG_DIR}/*.txt ${CONFIG_DIR}/xiaoya_backup
        INFO "完成备份小雅配置数据！"
        INFO "备份数据路径：${CONFIG_DIR}/xiaoya_backup"
    fi

    if ! grep "access.mypikpak.com" ${HOSTS_FILE_PATH}; then
        echo -e "127.0.0.1\taccess.mypikpak.com" >> ${HOSTS_FILE_PATH}
    fi

    docker_pull "haroldli/xiaoya-tvbox:${__choose_native}"

    if [ -n "${extra_parameters}" ]; then
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/data" \
            ${extra_parameters} \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:${__choose_native}
    else
        docker run -itd \
            -p "${HT_PORT}":4567 \
            -p "${ALIST_PORT}":80 \
            -e ALIST_PORT="${ALIST_PORT}" \
            -e MEM_OPT="${MEM_OPT}" \
            -e TZ=Asia/Shanghai \
            -v "${CONFIG_DIR}:/data" \
            --restart=always \
            --name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" \
            haroldli/xiaoya-tvbox:${__choose_native}
    fi

    INFO "安装完成！"
    INFO "浏览器访问 小雅Alist-TVBox 服务：${Sky_Blue}http://ip:${HT_PORT}${Font}, 默认用户密码: ${Sky_Blue}admin/admin${Font}"

}

function update_xiaoya_alist_tvbox() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新小雅Alist-TVBox${Blue} $i ${Font}\r"
        sleep 1
    done
    VOLUMES="$(docker inspect -f '{{range .Mounts}}{{if eq .Type "volume"}}{{println .}}{{end}}{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" | cut -d' ' -f2 | awk 'NF' | tr '\n' ' ')"
    # shellcheck disable=SC2034
    container_update_extra_command="sedsh '/\/opt\/atv\/data/d; \/opt\/alist\/data/d' "/tmp/container_update_$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)""
    container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker volume rm ${VOLUMES}

}

function uninstall_xiaoya_alist_tvbox() {

    local CLEAN_CONFIG IMAGE_NAME VOLUMES
    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载小雅Alist-TVBox${Blue} $i ${Font}\r"
        sleep 1
    done
    IMAGE_NAME="$(docker inspect --format='{{.Config.Image}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)")"
    VOLUMES="$(docker inspect -f '{{range .Mounts}}{{if eq .Type "volume"}}{{println .}}{{end}}{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)" | cut -d' ' -f2 | awk 'NF' | tr '\n' ' ')"
    docker stop "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rm "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)"
    docker rmi "${IMAGE_NAME}"
    docker volume rm ${VOLUMES}
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_tvbox_config_dir.txt)
            for dir in "${OLD_CONFIG_DIR}"/*/; do
                rm -rf "$dir"
            done
            rm -rf ${OLD_CONFIG_DIR}/*.db
        fi
    fi
    INFO "小雅Alist-TVBox卸载成功！"

}

function main_xiaoya_alist_tvbox() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}小雅Alist-TVBox${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    2)
        clear
        update_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    3)
        clear
        uninstall_xiaoya_alist_tvbox
        return_menu "main_xiaoya_alist_tvbox"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_alist_tvbox
        ;;
    esac

}

function install_xiaoya_115_cleaner() {

    local config_dir
    if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
        config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data$" | awk -F: '{print $1}')"
    fi
    if [ -z "${config_dir}" ]; then
        get_config_dir
        config_dir=${CONFIG_DIR}
    fi

    settings_115_cookie "${config_dir}"

    if [ ! -f "${config_dir}/115_key.txt" ]; then
        touch ${config_dir}/115_key.txt
        INFO "输入你的 115 回收站密码"
        INFO "注意：此选项为必填项，如果您关闭了回收站密码请手动开启并输入！"
        read -erp "Key:" password_key
        echo -e "${password_key}" > ${config_dir}/115_key.txt
    fi

    while true; do
        INFO "请选择 115 Cleaner 清理模式（默认 1）"
        INFO "1：标准模式，清空 /我的接收 下面的文件并同时清理回收站的对应文件"
        INFO "2：只清空 115云盘 回收站文件，不会清理其他地方的文件"
        INFO "3：清空 /我的接收 下面的文件并同时清空回收站"
        read -erp "CHOOSE_RUN_MODE:" CHOOSE_RUN_MODE
        [[ -z "${CHOOSE_RUN_MODE}" ]] && CHOOSE_RUN_MODE="1"
        if [ -f "${config_dir}/115_cleaner_all_recyclebin.txt" ]; then
            rm -rf "${config_dir}/115_cleaner_all_recyclebin.txt"
        fi
        if [ -f "${config_dir}/115_cleaner_only_recyclebin.txt" ]; then
            rm -rf "${config_dir}/115_cleaner_only_recyclebin.txt"
        fi
        case ${CHOOSE_RUN_MODE} in
        1)
            break
            ;;
        2)
            touch "${config_dir}/115_cleaner_only_recyclebin.txt"
            break
            ;;
        3)
            touch "${config_dir}/115_cleaner_all_recyclebin.txt"
            break
            ;;
        *)
            ERROR "输入无效，请重新选择"
            ;;
        esac
    done

    if [ -f "${config_dir}/ali2115.txt" ]; then
        while true; do
            INFO "是否将 ali2115 转存文件交由 115 Cleaner 清理 [Y/n]（默认 y）"
            read -erp "ali2115:" choose_ali2115
            [[ -z "${choose_ali2115}" ]] && choose_ali2115="y"
            if [[ ${choose_ali2115} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
    fi
    if [[ ${choose_ali2115} == [Yy] ]]; then
        touch "${config_dir}/115_cleaner_auto_set_ali2115.txt"
    fi

    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_115_cleaner")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
        extra_parameters=$(data_crep "w" "install_xiaoya_115_cleaner")
    fi

    docker_pull "ddsderek/xiaoya-115cleaner:latest"

    docker run -d \
        --name=xiaoya-115cleaner \
        -v "${config_dir}:/data" \
        --net=host \
        -e TZ=Asia/Shanghai \
        ${extra_parameters} \
        --restart=always \
        ddsderek/xiaoya-115cleaner:latest

    INFO "安装完成！"

}

function update_xiaoya_115_cleaner() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新115清理助手${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update xiaoya-115cleaner

}

function uninstall_xiaoya_115_cleaner() {

    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载115清理助手${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop xiaoya-115cleaner
    docker rm xiaoya-115cleaner
    docker rmi ddsderek/xiaoya-115cleaner:latest
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            for file in "${OLD_CONFIG_DIR}/115_cleaner_only_recyclebin.txt" "${OLD_CONFIG_DIR}/115_cleaner_all_recyclebin.txt" "${OLD_CONFIG_DIR}/115_key.txt"; do
                if [ -f "$file" ]; then
                    rm -f "$file"
                fi
            done
        fi
    fi
    INFO "115清理助手卸载成功！"

}

function main_xiaoya_115_cleaner() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}115 清理助手${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_115_cleaner
        return_menu "main_xiaoya_115_cleaner"
        ;;
    2)
        clear
        update_xiaoya_115_cleaner
        return_menu "main_xiaoya_115_cleaner"
        ;;
    3)
        clear
        uninstall_xiaoya_115_cleaner
        return_menu "main_xiaoya_115_cleaner"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_115_cleaner
        ;;
    esac

}

function install_xiaoya_proxy() {

    local config_dir
    if docker container inspect "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" > /dev/null 2>&1; then
        config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data$" | awk -F: '{print $1}')"
    else
        ERROR "请先安装小雅容器后再使用 Xiaoya Proxy！"
        exit 1
    fi
    if [ -z "${config_dir}" ]; then
        get_config_dir
        config_dir=${CONFIG_DIR}
    fi
    INFO "小雅配置文件目录：${config_dir}"
    container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${container_run_extra_parameters}" == "true" ]; then
        local RETURN_DATA
        RETURN_DATA="$(data_crep "r" "install_xiaoya_proxy")"
        if [ "${RETURN_DATA}" == "None" ]; then
            INFO "请输入其他参数（默认 无 ）"
            read -erp "Extra parameters:" extra_parameters
        else
            INFO "已读取您上次设置的参数：${RETURN_DATA} (默认不更改回车继续，如果需要更改请输入新参数)"
            read -erp "Extra parameters:" extra_parameters
            [[ -z "${extra_parameters}" ]] && extra_parameters=${RETURN_DATA}
        fi
        extra_parameters=$(data_crep "w" "install_xiaoya_proxy")
    fi
    if ! check_port "9988"; then
        ERROR "9988 端口被占用，请关闭占用此端口的程序！"
        exit 1
    fi
    docker_pull "ddsderek/xiaoya-proxy:latest"
    # shellcheck disable=SC2046
    docker run -d \
        --name=xiaoya-proxy \
        --restart=always \
        $(get_default_network "xiaoya-proxy") \
        ${extra_parameters} \
        -e TZ=Asia/Shanghai \
        ddsderek/xiaoya-proxy:latest
    if [[ "${OSNAME}" = "macos" ]]; then
        local_ip=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
    else
        local_ip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
    fi
    if [ -z "${local_ip}" ]; then
        WARN "请手动配置 ${config_dir}/xiaoya_proxy.txt 文件，内容为 http://小雅服务器IP:9988"
    else
        INFO "本机IP：${local_ip}"
        echo "http://${local_ip}:9988" > ${config_dir}/xiaoya_proxy.txt
        INFO "xiaoya_proxy.txt 配置完成！"
    fi
    docker restart "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    wait_xiaoya_start
    INFO "安装完成！"

}

function update_xiaoya_proxy() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新 Xiaoya Proxy${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update xiaoya-proxy

}

function uninstall_xiaoya_proxy() {

    while true; do
        INFO "是否${Red}删除配置文件${Font} [Y/n]（默认 Y 删除）"
        read -erp "Clean config:" CLEAN_CONFIG
        [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"
        if [[ ${CLEAN_CONFIG} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 Xiaoya Proxy${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop xiaoya-proxy
    docker rm xiaoya-proxy
    docker rmi ddsderek/xiaoya-proxy:latest
    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        INFO "清理配置文件..."
        if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt ]; then
            OLD_CONFIG_DIR=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)
            if [ -f "${OLD_CONFIG_DIR}/xiaoya_proxy.txt" ]; then
                rm -f "${OLD_CONFIG_DIR}/xiaoya_proxy.txt"
            fi
        fi
    fi
    INFO "Xiaoya Proxy 卸载成功！"

}

function main_xiaoya_proxy() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Xiaoya Proxy${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        install_xiaoya_proxy
        return_menu "main_xiaoya_proxy"
        ;;
    2)
        clear
        update_xiaoya_proxy
        return_menu "main_xiaoya_proxy"
        ;;
    3)
        clear
        uninstall_xiaoya_proxy
        return_menu "main_xiaoya_proxy"
        ;;
    0)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_proxy
        ;;
    esac

}

function install_xiaoya_aliyuntvtoken_connector() {

    CONFIG_DIR=$1

    if [ ! -f "${CONFIG_DIR}/open_tv_token_url.txt" ]; then
        INFO "当前未配置 阿里云盘 TV Token，开始进入 TV Token 配置流程..."
        qrcode_aliyunpan_tvtoken "${CONFIG_DIR}"
    else
        INFO "阿里云盘 TV Token 当前已配置！"
    fi

    if ! check_port "34278"; then
        ERROR "34278 端口被占用，请关闭占用此端口的程序！"
        exit 1
    fi

    docker_pull "ddsderek/xiaoya-glue:aliyuntvtoken_connector"

    # shellcheck disable=SC2046
    docker run -d \
        $(get_default_network "xiaoya-aliyuntvtoken_connector") \
        --name=xiaoya-aliyuntvtoken_connector \
        --restart=always \
        ddsderek/xiaoya-glue:aliyuntvtoken_connector

    sleep 2

    get_docker0_url
    local xiaoya_name aliyuntvtoken_connector_addr local_ip xiaoya_running
    xiaoya_name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    xiaoya_running=false
    if docker container inspect "${xiaoya_name}" > /dev/null 2>&1; then
        case "$(docker inspect --format='{{.State.Status}}' "${xiaoya_name}")" in
        "running")
            xiaoya_running=true
            ;;
        esac
    fi
    function set_local_ip() {
        if [[ "${OSNAME}" = "macos" ]]; then
            local_ip=$(ifconfig "$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')" | grep 'inet ' | awk '{print$2}')
        else
            local_ip=$(ip address | grep inet | grep -v 172.17 | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | sed 's/addr://' | head -n1 | cut -f1 -d"/")
        fi
        if [ -z "${local_ip}" ]; then
            WARN "请手动配置 ${CONFIG_DIR}/open_tv_token_url.txt 文件，内容为 http://小雅服务器IP:34278/oauth/alipan/token"
        else
            INFO "本机IP：${local_ip}"
            aliyuntvtoken_connector_addr="http://${local_ip}:34278/oauth/alipan/token"
        fi
    }
    if [ "${xiaoya_running}" == "true" ]; then
        if docker exec -it "${xiaoya_name}" curl -siL -m 10 http://127.0.0.1:34278/oauth/alipan/token | grep 405; then
            aliyuntvtoken_connector_addr="http://127.0.0.1:34278/oauth/alipan/token"
        elif docker exec -it "${xiaoya_name}" curl -siL -m 10 http://${docker0}:34278/oauth/alipan/token | grep 405; then
            aliyuntvtoken_connector_addr="http://${docker0}:34278/oauth/alipan/token"
        else
            set_local_ip
        fi
    else
        set_local_ip
    fi
    if [ -n "${aliyuntvtoken_connector_addr}" ]; then
        INFO "本地阿里云盘 TV Token 鉴权接口地址：${aliyuntvtoken_connector_addr}"
        echo "${aliyuntvtoken_connector_addr}" > "${CONFIG_DIR}/open_tv_token_url.txt"
    fi

    if docker container inspect "${xiaoya_name}" > /dev/null 2>&1; then
        docker restart "${xiaoya_name}"
        sleep 5
        wait_xiaoya_start
    fi

    INFO "安装完成！"

}

function update_xiaoya_aliyuntvtoken_connector() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新 xiaoya-aliyuntvtoken_connector${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update xiaoya-aliyuntvtoken_connector

}

function uninstall_xiaoya_aliyuntvtoken_connector() {

    while true; do
        INFO "是否停止使用 阿里云盘 TV Token 配置 [Y/n]（默认 n）"
        read -erp "Use_TV_Token:" USE_TV_TOKEN
        [[ -z "${USE_TV_TOKEN}" ]] && USE_TV_TOKEN="n"
        if [[ ${USE_TV_TOKEN} == [YyNn] ]]; then
            break
        else
            ERROR "非法输入，请输入 [Y/n]"
        fi
    done

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 xiaoya-aliyuntvtoken_connector${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop xiaoya-aliyuntvtoken_connector
    docker rm xiaoya-aliyuntvtoken_connector
    docker rmi ddsderek/xiaoya-glue:aliyuntvtoken_connector

    local xiaoya_name config_dir
    xiaoya_name="$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
    if docker container inspect "${xiaoya_name}" > /dev/null 2>&1; then
        config_dir="$(docker inspect -f '{{ range .Mounts }}{{ if eq .Destination "/data" }}{{ .Source }}{{ end }}{{ end }}' "${xiaoya_name}")"
    elif [ -f "${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt" ]; then
        config_dir="$(cat ${DDSREM_CONFIG_DIR}/xiaoya_alist_config_dir.txt)"
    else
        get_config_dir
        config_dir="${CONFIG_DIR}"
    fi
    INFO "小雅容器配置目录：${config_dir}"

    if [[ ${USE_TV_TOKEN} == [Yy] ]]; then
        rm -f "${config_dir}/open_tv_token_url.txt"
        rm -f "${config_dir}/myopentoken.txt"
        while true; do
            INFO "是否配置阿里云盘 Open Token（myopentoken文件） [Y/n]（默认 y）"
            read -erp "Set_Open_Token:" SET_OPEN_TOKEN
            [[ -z "${SET_OPEN_TOKEN}" ]] && SET_OPEN_TOKEN="y"
            if [[ ${SET_OPEN_TOKEN} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${SET_OPEN_TOKEN} == [Yy] ]]; then
            settings_aliyunpan_opentoken "${config_dir}" force
        fi
    else
        INFO "切换使用公共鉴权接口：https://www.voicehub.top/api/v1/oauth/alipan/token"
        echo "https://www.voicehub.top/api/v1/oauth/alipan/token" > "${config_dir}/open_tv_token_url.txt"
    fi

    if docker container inspect "${xiaoya_name}" > /dev/null 2>&1; then
        docker restart "${xiaoya_name}"
        sleep 5
        wait_xiaoya_start
    fi

    INFO "xiaoya-aliyuntvtoken_connector 卸载成功！"

}

function main_xiaoya_aliyuntvtoken_connector() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}阿里云盘 TV Token 令牌刷新接口（xiaoya-aliyuntvtoken_connector）${Font}\n"
    echo -e "1、安装"
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-3]:" num
    case "$num" in
    1)
        clear
        get_config_dir
        install_xiaoya_aliyuntvtoken_connector "${CONFIG_DIR}"
        return_menu "main_xiaoya_aliyuntvtoken_connector"
        ;;
    2)
        clear
        update_xiaoya_aliyuntvtoken_connector
        return_menu "main_xiaoya_aliyuntvtoken_connector"
        ;;
    3)
        clear
        uninstall_xiaoya_aliyuntvtoken_connector
        return_menu "main_xiaoya_aliyuntvtoken_connector"
        ;;
    0)
        clear
        main_other_tools
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-3]'
        main_xiaoya_aliyuntvtoken_connector
        ;;
    esac

}

function main_docker_compose() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}Docker Compose 小雅及全家桶${Font}\n"
    echo -e "${Sky_Blue}Docker Compose 安装方式由 https://link.monlor.com/ 更新维护，在此表示感谢！"
    echo -e "具体详细介绍请看项目README：https://github.com/monlor/docker-xiaoya${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-2]:" num
    case "$num" in
    1)
        clear
        while true; do
            INFO "是否使用加速源 [Y/n]（默认 N）"
            read -erp "USE_PROXY:" USE_PROXY
            [[ -z "${USE_PROXY}" ]] && USE_PROXY="n"
            if [[ ${USE_PROXY} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${USE_PROXY} == [Yy] ]]; then
            export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com
        fi
        bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
        return_menu "main_docker_compose"
        ;;
    2)
        clear
        while true; do
            INFO "是否使用加速源 [Y/n]（默认 N）"
            read -erp "USE_PROXY:" USE_PROXY
            [[ -z "${USE_PROXY}" ]] && USE_PROXY="n"
            if [[ ${USE_PROXY} == [YyNn] ]]; then
                break
            else
                ERROR "非法输入，请输入 [Y/n]"
            fi
        done
        if [[ ${USE_PROXY} == [Yy] ]]; then
            export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com
        fi
        bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
        return_menu "main_docker_compose"
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-2]'
        main_docker_compose
        ;;
    esac

}

function init_container_name() {

    if [ ! -d ${DDSREM_CONFIG_DIR}/container_name ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}/container_name
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt ]; then
        xiaoya_alist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    else
        echo 'xiaoya' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt
        xiaoya_alist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt ]; then
        xiaoya_emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    else
        echo 'emby' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt
        xiaoya_emby_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_emby_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt ]; then
        xiaoya_jellyfin_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)
    else
        echo 'jellyfin' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt
        xiaoya_jellyfin_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_jellyfin_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt ]; then
        xiaoya_resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    else
        echo 'resilio' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt
        xiaoya_resilio_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_resilio_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt ]; then
        xiaoya_tvbox_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    else
        echo 'xiaoya-tvbox' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt
        xiaoya_tvbox_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_tvbox_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt ]; then
        xiaoya_onelist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    else
        echo 'onelist' > ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt
        xiaoya_onelist_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_onelist_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt ]; then
        portainer_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    else
        echo 'portainer' > ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt
        portainer_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/portainer_name.txt)
    fi

    if [ -f ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt ]; then
        auto_symlink_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)
    else
        echo 'auto_symlink' > ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt
        auto_symlink_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/auto_symlink_name.txt)
    fi

}

function change_container_name() {

    INFO "请输入新的容器名称"
    read -erp "Container name:" container_name
    [[ -z "${container_name}" ]] && container_name=$(cat ${DDSREM_CONFIG_DIR}/container_name/"${1}".txt)
    echo "${container_name}" > ${DDSREM_CONFIG_DIR}/container_name/"${1}".txt
    clear
    container_name_settings

}

function container_name_settings() {

    init_container_name

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}容器名称设置${Font}\n"
    echo -e "1、更改 小雅 容器名                 （当前：${Green}${xiaoya_alist_name}${Font}）"
    echo -e "2、更改 小雅Emby 容器名             （当前：${Green}${xiaoya_emby_name}${Font}）"
    echo -e "3、更改 Resilio 容器名              （当前：${Green}${xiaoya_resilio_name}${Font}）"
    echo -e "4、更改 小雅Alist-TVBox 容器名      （当前：${Green}${xiaoya_tvbox_name}${Font}）"
    echo -e "5、更改 Onelist 容器名              （当前：${Green}${xiaoya_onelist_name}${Font}）"
    echo -e "6、更改 Portainer 容器名            （当前：${Green}${portainer_name}${Font}）"
    echo -e "7、更改 Auto_Symlink 容器名         （当前：${Green}${auto_symlink_name}${Font}）"
    echo -e "8、更改 Jellyfin 容器名             （当前：${Green}${xiaoya_jellyfin_name}${Font}）"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-8]:" num
    case "$num" in
    1)
        change_container_name "xiaoya_alist_name"
        ;;
    2)
        change_container_name "xiaoya_emby_name"
        ;;
    3)
        change_container_name "xiaoya_resilio_name"
        ;;
    4)
        change_container_name "xiaoya_tvbox_name"
        ;;
    5)
        change_container_name "xiaoya_onelist_name"
        ;;
    6)
        change_container_name "portainer_name"
        ;;
    7)
        change_container_name "auto_symlink_name"
        ;;
    8)
        change_container_name "xiaoya_jellyfin_name"
        ;;
    0)
        clear
        main_advanced_configuration
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-8]'
        container_name_settings
        ;;
    esac

}

function reset_script_configuration() {

    INFO "是否${Red}删除所有脚本配置文件${Font} [Y/n]（默认 Y 删除）"
    read -erp "Clean config:" CLEAN_CONFIG
    [[ -z "${CLEAN_CONFIG}" ]] && CLEAN_CONFIG="y"

    if [[ ${CLEAN_CONFIG} == [Yy] ]]; then
        for i in $(seq -w 3 -1 0); do
            echo -en "即将开始清理配置文件${Blue} $i ${Font}\r"
            sleep 1
        done
        FILES_TO_REMOVE=(
            "xiaoya_alist_tvbox_config_dir.txt"
            "xiaoya_alist_media_dir.txt"
            "xiaoya_alist_config_dir.txt"
            "resilio_config_dir.txt"
            "portainer_config_dir.txt"
            "onelist_config_dir.txt"
            "container_run_extra_parameters.txt"
            "auto_symlink_config_dir.txt"
            "data_downloader.txt"
            "disk_capacity_detection.txt"
            "xiaoya_connectivity_detection.txt"
            "image_mirror.txt"
            "image_mirror_user.txt"
            "default_network.txt"
        )
        for file in "${FILES_TO_REMOVE[@]}"; do
            rm -f ${DDSREM_CONFIG_DIR}/$file
        done
        rm -rf \
            ${DDSREM_CONFIG_DIR}/container_name \
            ${DDSREM_CONFIG_DIR}/data_crep
        INFO "清理完成！"

        for i in $(seq -w 3 -1 0); do
            echo -en "即将返回主界面并重新生成默认配置${Blue} $i ${Font}\r"
            sleep 1
        done

        first_init
        clear
        main_return
    else
        return 0
    fi

}

function main_advanced_configuration() {

    __container_run_extra_parameters=$(cat ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt)
    if [ "${__container_run_extra_parameters}" == "true" ]; then
        _container_run_extra_parameters="${Green}开启${Font}"
    elif [ "${__container_run_extra_parameters}" == "false" ]; then
        _container_run_extra_parameters="${Red}关闭${Font}"
    else
        _container_run_extra_parameters="${Red}错误${Font}"
    fi

    __disk_capacity_detection=$(cat ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt)
    if [ "${__disk_capacity_detection}" == "true" ]; then
        _disk_capacity_detection="${Green}开启${Font}"
    elif [ "${__disk_capacity_detection}" == "false" ]; then
        _disk_capacity_detection="${Red}关闭${Font}"
    else
        _disk_capacity_detection="${Red}错误${Font}"
    fi

    __xiaoya_connectivity_detection=$(cat ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt)
    if [ "${__xiaoya_connectivity_detection}" == "true" ]; then
        _xiaoya_connectivity_detection="${Green}开启${Font}"
    elif [ "${__xiaoya_connectivity_detection}" == "false" ]; then
        _xiaoya_connectivity_detection="${Red}关闭${Font}"
    else
        _xiaoya_connectivity_detection="${Red}错误${Font}"
    fi

    _default_network=$(cat "${DDSREM_CONFIG_DIR}/default_network.txt")

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}高级配置${Font}\n"
    echo -e "1、容器名称设置"
    echo -e "2、开启/关闭 容器运行额外参数添加             当前状态：${_container_run_extra_parameters}"
    echo -e "3、重置脚本配置"
    echo -e "4、开启/关闭 磁盘容量检测                     当前状态：${_disk_capacity_detection}"
    echo -e "5、开启/关闭 小雅连通性检测                   当前状态：${_xiaoya_connectivity_detection}"
    echo -e "6、Docker镜像源选择"
    echo -e "7、非可选网络模式容器默认网络模式             当前状态：${Blue}${_default_network}${Font}"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-7]:" num
    case "$num" in
    1)
        clear
        container_name_settings
        ;;
    2)
        if [ "${__container_run_extra_parameters}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        else
            echo 'false' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
        fi
        clear
        main_advanced_configuration
        ;;
    3)
        clear
        reset_script_configuration
        return_menu "main_advanced_configuration"
        ;;
    4)
        if [ "${__disk_capacity_detection}" == "true" ]; then
            echo 'false' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        elif [ "${__disk_capacity_detection}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        else
            echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
        fi
        clear
        main_advanced_configuration
        ;;
    5)
        if [ "${__xiaoya_connectivity_detection}" == "true" ]; then
            echo 'false' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        elif [ "${__xiaoya_connectivity_detection}" == "false" ]; then
            echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        else
            echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
        fi
        clear
        main_advanced_configuration
        ;;
    6)
        clear
        choose_image_mirror "main_advanced_configuration"
        ;;
    7)
        if [ "${_default_network}" == "host" ]; then
            echo 'bridge' > ${DDSREM_CONFIG_DIR}/default_network.txt
        elif [ "${_default_network}" == "bridge" ]; then
            echo 'host' > ${DDSREM_CONFIG_DIR}/default_network.txt
        else
            echo 'host' > ${DDSREM_CONFIG_DIR}/default_network.txt
        fi
        clear
        main_advanced_configuration
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-7]'
        main_advanced_configuration
        ;;
    esac

}

function main_other_tools() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}其他工具${Font}\n"
    echo -ne "${INFO} 界面加载中...${Font}\r"
    echo -e "1、安装/更新/卸载 Portainer                       当前状态：$(judgment_container "${portainer_name}")
2、安装/更新/卸载 Auto_Symlink                    当前状态：$(judgment_container "${auto_symlink_name}")
3、安装/更新/卸载 Onelist                         当前状态：$(judgment_container "${xiaoya_onelist_name}")
4、安装/更新/卸载 Xiaoya Proxy                    当前状态：$(judgment_container xiaoya-proxy)
5、安装/更新/卸载 Xiaoya aliyuntvtoken_connector  当前状态：$(judgment_container xiaoya-aliyuntvtoken_connector)"
    echo -e "6、查看系统磁盘挂载"
    echo -e "7、安装/卸载 CasaOS"
    echo -e "8、AI老G 安装脚本"
    echo -e "0、返回上级"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-8]:" num
    case "$num" in
    1)
        clear
        main_portainer
        ;;
    2)
        clear
        main_auto_symlink
        ;;
    3)
        clear
        main_onelist
        ;;
    4)
        clear
        main_xiaoya_proxy
        ;;
    5)
        clear
        main_xiaoya_aliyuntvtoken_connector
        ;;
    6)
        clear
        INFO "系统磁盘挂载情况:"
        show_disk_mount
        INFO "按任意键返回菜单"
        read -rs -n 1 -p ""
        clear
        main_other_tools
        ;;
    7)
        clear
        main_casaos
        ;;
    8)
        clear
        bash <(curl -sSLf https://xy.ggbond.org/xy/xy_install.sh)
        ;;
    0)
        clear
        main_return
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-8]'
        main_other_tools
        ;;
    esac

}

function main_return() {

    local out_tips
    cat /tmp/xiaoya_alist
    echo -ne "${INFO} 主界面加载中...${Font}\r"
    if ! curl -s -o /dev/null -m 4 -w '%{time_total}' --head --request GET "$(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")" &> /dev/null; then
        if auto_choose_image_mirror; then
            out_tips="${Green}提示：已为您自动配置Docker镜像源地址为: $(cat "${DDSREM_CONFIG_DIR}/image_mirror.txt")${Font}\n"
        else
            out_tips="${Red}警告：当前环境无法访问Docker镜像仓库，请输入96进入Docker镜像源设置更改镜像源${Font}\n"
        fi
    fi
    # shellcheck disable=SC2154
    echo -e "${out_tips}1、安装/更新/卸载 小雅Alist & 账号管理        当前状态：$(judgment_container "${xiaoya_alist_name}")
2、安装/更新/卸载 小雅Emby全家桶              当前状态：$(judgment_container "${xiaoya_emby_name}")
3、安装/卸载 小雅Jellyfin全家桶（已弃用）     当前状态：$(judgment_container "${xiaoya_jellyfin_name}")
4、安装/更新/卸载 小雅助手（xiaoyahelper）    当前状态：$(judgment_container xiaoyakeeper)
5、安装/更新/卸载 小雅Alist-TVBox（非原版）   当前状态：$(judgment_container "${xiaoya_tvbox_name}")
6、安装/更新/卸载 115清理助手                 当前状态：$(judgment_container xiaoya-115cleaner)
7、Docker Compose 安装/卸载 小雅及全家桶（实验性功能）
8、其他工具 | Script info: ${DATE_VERSION} OS: ${_os},${OSNAME},${is64bit}
9、高级配置 | Docker version: ${Blue}${DOCKER_VERSION}${Font} ${IP_CITY}
0、退出脚本 | Thanks: ${Sky_Blue}heiheigui,xiaoyaLiu,Harold,AI老G,monlor,Rik${Font}
——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [0-9]:" num
    case "$num" in
    1)
        clear
        main_xiaoya_alist
        ;;
    2)
        clear
        main_xiaoya_all_emby
        ;;
    3)
        clear
        main_xiaoya_all_jellyfin
        ;;
    4)
        clear
        main_xiaoyahelper
        ;;
    5)
        clear
        main_xiaoya_alist_tvbox
        ;;
    6)
        clear
        main_xiaoya_115_cleaner
        ;;
    7)
        clear
        main_docker_compose
        ;;
    8)
        clear
        main_other_tools
        ;;
    9)
        clear
        main_advanced_configuration
        ;;
    96)
        clear
        choose_image_mirror "main_return"
        ;;
    fuckaliyun)
        clear
        INFO "AliyunPan ありがとう、あなたのせいで世界は爆発する"
        config_dir="$(docker inspect --format='{{range $v,$conf := .Mounts}}{{$conf.Source}}:{{$conf.Destination}}{{$conf.Type}}~{{end}}' "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)" | tr '~' '\n' | grep bind | sed 's/bind//g' | grep ":/data$" | awk -F: '{print $1}')"
        if [ -n "${config_dir}" ]; then
            qrcode_aliyunpan_tvtoken "${config_dir}"
            INFO "开始更新小雅容器..."
            container_update "$(cat ${DDSREM_CONFIG_DIR}/container_name/xiaoya_alist_name.txt)"
        else
            ERROR "小雅配置文件目录获取失败咯！请检查小雅容器是否已创建！"
            exit 1
        fi
        return_menu "main_return"
        ;;
    0)
        clear
        exit 0
        ;;
    *)
        clear
        ERROR '请输入正确数字 [0-9]'
        main_return
        ;;
    esac
}

function first_init() {

    INFO "获取系统信息中..."
    get_os

    INFO "获取 IP 地址中..."
    CITY="$(curl -fsSL -m 10 -s http://ipinfo.io/json | sed -n 's/.*"city": *"\([^"]*\)".*/\1/p')"
    if [ -n "${CITY}" ]; then
        IP_CITY="IP City: ${Yellow}${CITY}${Font}"
        INFO "获取 IP 地址成功！"
    fi

    INFO "检查 Docker 版本"
    DOCKER_VERSION="$(docker -v | sed "s/Docker version //g" | cut -d',' -f1)"

    if [ ! -d ${DDSREM_CONFIG_DIR} ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}
    fi
    # Fix https://github.com/DDS-Derek/xiaoya-alist/commit/a246bc582393b618b564e3beca2b9e1d40800a5d 中media目录保存错误
    if [ -f /xiaoya_alist_media_dir.txt ]; then
        mv /xiaoya_alist_media_dir.txt ${DDSREM_CONFIG_DIR}
    fi
    INFO "初始化容器名称中..."
    init_container_name

    if [ ! -f ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt ]; then
        echo 'false' > ${DDSREM_CONFIG_DIR}/container_run_extra_parameters.txt
    fi

    if [ ! -d ${DDSREM_CONFIG_DIR}/data_crep ]; then
        mkdir -p ${DDSREM_CONFIG_DIR}/data_crep
    fi

    if [ ! -f ${DDSREM_CONFIG_DIR}/data_downloader.txt ]; then
        if [ "$OSNAME" = "ugos" ] || [ "$OSNAME" = "ugos pro" ]; then
            echo 'wget' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        else
            echo 'aria2' > ${DDSREM_CONFIG_DIR}/data_downloader.txt
        fi
    fi

    if [ ! -f ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt ]; then
        echo 'true' > ${DDSREM_CONFIG_DIR}/disk_capacity_detection.txt
    fi

    if [ ! -f ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt ]; then
        echo 'true' > ${DDSREM_CONFIG_DIR}/xiaoya_connectivity_detection.txt
    fi

    if [ ! -f "${DDSREM_CONFIG_DIR}/default_network.txt" ]; then
        echo 'host' > "${DDSREM_CONFIG_DIR}/default_network.txt"
    fi

    INFO "设置 Docker 镜像源中..."
    if [ ! -f "${DDSREM_CONFIG_DIR}/image_mirror.txt" ]; then
        if ! auto_choose_image_mirror; then
            echo 'docker.io' > ${DDSREM_CONFIG_DIR}/image_mirror.txt
        fi
    fi
    if [ ! -f "${DDSREM_CONFIG_DIR}/image_mirror_user.txt" ]; then
        touch ${DDSREM_CONFIG_DIR}/image_mirror_user.txt
    fi

    INFO "清理旧配置文件中..."
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_url.txt
    fi
    if [ -f ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt ]; then
        rm -rf ${DDSREM_CONFIG_DIR}/xiaoya_emby_api.txt
    fi

    if [ ! -f "${DDSREM_CONFIG_DIR}/勿删_小雅周边脚本配置目录" ]; then
        touch "${DDSREM_CONFIG_DIR}/勿删_小雅周边脚本配置目录"
    fi

    if [ -f /tmp/xiaoya_alist ]; then
        rm -rf /tmp/xiaoya_alist
    fi
    if ! curl -sL https://ddsrem.com/xiaoya/xiaoya_alist -o /tmp/xiaoya_alist; then
        if ! curl -sL https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist -o /tmp/xiaoya_alist; then
            curl -sL https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist -o /tmp/xiaoya_alist
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://raw.githubusercontent.com/DDS-Derek/xiaoya-alist/master/xiaoya_alist)\"'" >> /etc/profile
            fi
        else
            if ! grep -q 'alias xiaoya' /etc/profile; then
                echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://fastly.jsdelivr.net/gh/DDS-Derek/xiaoya-alist@latest/xiaoya_alist)\"'" >> /etc/profile
            fi
        fi
    else
        if ! grep -q 'alias xiaoya' /etc/profile; then
            echo -e "alias xiaoya='bash -c \"\$(curl -sLk https://ddsrem.com/xiaoya_install.sh)\"'" >> /etc/profile
        fi
    fi
    INFO "初始化完成！"
    sleep 1

}

clear
INFO "初始化中，请稍等...."
root_need
if [ ! -d "/tmp/xiaoya_alist_tmp" ]; then
    mkdir -p /tmp/xiaoya_alist_tmp
fi
for file in "base" "image_mirror" "auto_symlink" "jellyfin" "portainer" "onelist" "casaos"; do
    if ! curl -sSLf "https://gitee.com/ddsrem/xiaoya-alist-base/raw/master/${file}.sh" -o "/tmp/xiaoya_alist_tmp/${file}.sh"; then
        ERROR "${file} 基础库获取失败！"
        ERROR "请检查是否能访问 gitee.com！"
        exit 1
    else
        source "/tmp/xiaoya_alist_tmp/${file}.sh"
        rm -f "/tmp/xiaoya_alist_tmp/${file}.sh"
        INFO "${file} 基础库加载成功！"
    fi
done
rm -rf /tmp/xiaoya_alist_tmp
first_init
clear
if [ ! "$*" ]; then
    main_return
else
    "$@"
fi
