#!/bin/bash


curl -sL "https://trueprepper.com/survival-pdfs-downloads/" | grep -oP 'https?://[^"]+\.pdf' | sort -u > pdf_list.txt
wget -i pdf_list.txt -A pdf -nc -nv --wait=1 --random-wait 
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Survival PDF Archive</title>
    <style>
        body { font-family: sans-serif; background: #1a1a1a; color: #eee; padding: 20px; }
        h1 { color: #ffcc00; border-bottom: 2px solid #333; }
        ul { list-style: none; padding: 0; }
        li { margin: 8px 0; padding: 10px; background: #2a2a2a; border-radius: 4px; }
        a { color: #44ff44; text-decoration: none; word-break: break-all; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>True Prepper PDFs</h1>
    <p>Total : $(ls -1 *.pdf | wc -l) files</p>
    <ul>
EOF

#PDF link creation
for file in *.pdf; do
    echo "        <li><a href=\"$file\" target=\"_blank\">$file</a></li>" >> index.html
done

cat <<EOF >> index.html
</ul>
</body>
</html>
EOF
rm -f pdf_list.txt
if [[ -z $(ls -A *.pdf) ]]; then
    echo -e "$MSGRED" "$SRVMSG" "failed to download English survival PDFs.${MSGNC}"
    exit 1
else
    echo -e "$MSGGREEN" "$SRVMSG" "English survival PDFs downloaded successfully.${MSGNC}"
fi
