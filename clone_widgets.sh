# make a place to put .wigt files
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d $DIR/app/fuel/app/tmp/widget_packages ]; then
	mkdir $DIR/app/fuel/app/tmp/widget_packages
fi

# clear any previous .wigt files
rm -rf $DIR/app/fuel/app/tmp/widget_packages/*

# fresh clone of all configured widgets and copy .wigt files to be installed
for i in $(grep -oh '\<git.*\.git\>' $DIR/app/fuel/packages/materia/config/widgets.php); do
	rm -rf $DIR/app/fuel/app/tmp/widgetsrc
	git clone $i --depth=1 $DIR/app/fuel/app/tmp/widgetsrc
	cp $DIR/app/fuel/app/tmp/widgetsrc/_output/*.wigt $DIR/app/fuel/app/tmp/widget_packages/
	rm -rf $DIR/app/fuel/app/tmp/widgetsrc
done
