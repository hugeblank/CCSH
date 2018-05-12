while inotifywait -e modify /tmp/render.sh; do
 ./tmp/render.sh; 
done