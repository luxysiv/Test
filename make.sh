#!/bin/bash
input_file="domain.txt"
output_file="hosts.txt"
sort "$input_file" | uniq | while IFS= read -r line; do
   host_line="0.0.0.0 $line"
   echo "$host_line" >> "$output_file"
done < "$input_file" | sort
