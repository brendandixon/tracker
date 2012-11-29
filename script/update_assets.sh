echo "Updating assets..."

BASE="base/base.css base/grid.css base/reset.css"
CONTENT="content/content_priority1.css content/content_priority2.css content/content_priority3.css"
LAYOUT="layout/footer.css layout/header.css"
WIDGETS="widgets/aws-icons.css widgets/buttons.css widgets/flexible.css widgets/form-controls.css widgets/status-colors.css widgets/table.css"
for sheet in $BASE $CONTENT $LAYOUT $WIDGETS
do
	echo "  $sheet"
	curl -s -o ./app/assets/stylesheets/$sheet http://10.61.104.132/styles/$sheet
done

IMAGES0="icon-sprite.png logoaws.png nudge-icon-arrow-down.png nudge-icon-arrow-lr.png nudge-icon-arrow-up.png nudge-icon-return.png"
IMAGES1="Blue_Button_Spinner.gif Gray_Button_Spinner.gif"
for image in $IMAGES0 $IMAGES1
do
	echo "  $image"
	curl -s -o ./app/assets/images/$image http://10.61.104.132/images/$image
done


SCRIPTS="dombuilder.min.js form-controls.js jquery.js jquery.tablesorter.min.js"
for script in $SCRIPTS
do
	echo "  $script"
	curl -s -o ./app/assets/scripts/$script http://10.61.104.132/scripts/$script
done
