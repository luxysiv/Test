#!/bin/bash
domain_file="domain.txt"
hosts_file="hosts.txt"
while IFS= read -r domain; do
  echo "0.0.0.0 $domain" >> "$hosts_file"
done < "$domain_file"
sort -u -o "$hosts_file" "$hosts_file"
