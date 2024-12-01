from aligo import Aligo

with open('/data/mytoken.txt', 'r') as file:
    refresh_token = file.readline().strip()
ali = Aligo(refresh_token=refresh_token)

# 这里默认使用资源盘
v2_user = ali.v2_user_get()
resource_drive_id = v2_user.resource_drive_id
ali.default_drive_id = resource_drive_id

file_list = ali.get_file_list()
folder_id = ''
for folder in file_list:
    if folder.name == '小雅转存文件夹':
        folder_id = folder.file_id
        break
if not folder_id:
    folder_id = ali.create_folder(name='小雅转存文件夹').file_id

print(folder_id)
