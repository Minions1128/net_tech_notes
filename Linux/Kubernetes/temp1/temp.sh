while true;do
    echo $(date) >> /data/index.html
    sleep 2
    tail -10 /data/index.html > /data/1
    mv /data/1 /data/index.html
done
