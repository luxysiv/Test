#!/bin/bash

# Tên tệp văn bản gốc
input_file="domain.txt"
# Tên tệp văn bản mới
output_file="hosts.txt"

# Mảng để lưu trữ các dòng duy nhất
unique_lines=()

# Đọc từng dòng trong tệp văn bản và loại bỏ dòng trùng
while IFS= read -r line; do
   # Kiểm tra xem dòng đã có trong mảng unique_lines chưa
   if ! [[ "${unique_lines[*]}" =~ (^|[[:space:]])"$line"($|[[:space:]]) ]]; then
      # Lưu dòng vào mảng unique_lines và ghi vào tệp văn bản mới
      unique_lines+=("$line")
      modified_line="0.0.0.0 $line"
      echo "$modified_line" >> "$output_file"
   fi
done < <(sort "$input_file")
