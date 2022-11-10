#### morphing Yeo-networks to subjects space + creating confidence interval maps on the volume
## Author: Ehsan Tadayon,MD [ sunny.tadayon@gmail.com / stadayon@bidmc.harvard.edu ]
## Date: 17 March, 2017
## Updated: 7 June, 2018
## Updated: 8 September, 2018

### how to use this code:
###### bash yeo2subject.sh <subject> <nNet>


subj=$1
nNet=$2
SUBJECTS_DIR=$3

export SUBJECTS_DIR=$SUBJECTS_DIR

### copying fsaverage_star

FILE=$SUBJECTS_DIR/fsaverage_star
if [ -f "$FILE" ]; then
	echo "fsaverage_star exists in SUBJECTS_DIR."
else
	cp -r fsaverage_star $SUBJECTS_DIR
fi


# Yeo annotation to subject's annotation
echo **** Yeo annotation to subjects annotation ****

for hemi in lh rh;do
mri_surf2surf --srcsubject fsaverage_star --sval-annot Yeo2011_${nNet}Networks_N1000 --hemi $hemi --trgsubject $subj --tval ${hemi}.Yeo2011_${nNet}Networks_N1000
done

### annotation to label
echo **** Yeo annotation in subjects surface to label ****

for hemi in lh rh;do
mri_annotation2label --subject $subj --hemi $hemi --annotation Yeo2011_${nNet}Networks_N1000 --outdir ${SUBJECTS_DIR}/${subj}/label
done

### label to volume in freesurfer
for hemi in lh rh;do
for net in $(seq 1 1 ${nNet});do
mri_label2vol --label ${SUBJECTS_DIR}/${subj}/label/${hemi}.${nNet}Networks_${net}.label --subject $subj --hemi $hemi --identity --temp ${SUBJECTS_DIR}/${subj}/mri/T1.mgz --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz --proj frac 0 1 0.01
done
done

### dilate and erode to get better ROIs
for hemi in lh rh; do
for net in $(seq 1 1 ${nNet}); do
mri_binarize --dilate 1 --erode 1 --i ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz --min 1 --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz
done
done

## tidying up:
for hemi in lh rh; do
for net in $(seq 1 1 ${nNet}); do
mris_calc -o ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz mul ${SUBJECTS_DIR}/${subj}/mri/${hemi}.ribbon.mgz
done
done

## move to native space
#for hemi in lh rh;do
#for net in $(seq 1 1 ${nNet});do
#mri_label2vol --seg ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz --temp ${SUBJECTS_DIR}/${subj}/mri/rawavg.mgz --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}-in-#rawavg.nii.gz --regheader ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz --proj frac 0 1 0.01
#done
#done

## move to native space ( version 2.0):
#for hemi in lh rh; do
#for net in $(seq 1 1 ${nNet}); do
#mri_vol2vol --mov ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}.mgz --targ ${SUBJECTS_DIR}/${subj}/mri/rawavg.mgz --regheader --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}.${nNet}Networks_${net}-in-rawavg.nii.gz --no-save-reg
#done
#done

################################## network confidence map to subject surface ############################################

for hemi in lh rh;do
cp $SUBJECTS_DIR/fsaverage/label/${hemi}.Yeo2011_${nNet}NetworksConfidence_N1000.mgh $SUBJECTS_DIR/fsaverage/surf/${hemi}.7netci
done

# resample Yeo confidence map from fsaverage_star ( a copy of fsaverage) to subject's surface

for hemi in lh rh; do
mri_surf2surf --srcsubject fsaverage_star --srcsurfval ${nNet}netci --trgsubject $subj --trgsurfval ${nNet}netci --hemi $hemi --src_type curv --trg_type curv
done

# resample confidence map from subject's surface to subject's volume.

### old version of how I used to do it:

#for hemi in lh rh;do
#mri_surf2vol --hemi ${hemi} --template ${SUBJECTS_DIR}/${subj}/mri/orig.mgz --outvol ${SUBJECTS_DIR}/${subj}/mri/${hemi}_${nNet}netci.mgz --surfval ${SUBJECTS_DIR}/${subj}/surf/${hemi}.${nNet}netci --fillribbon --volregidentity $subj
#done

### new version ( it uses method1 of mri_surf2vol which does not leave any holes)
for hemi in lh rh; do
mri_surf2vol --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}_${nNet}netci.mgz  --subject ${subj} --so ${SUBJECTS_DIR}/${subj}/surf/${hemi}.white ${SUBJECTS_DIR}/${subj}/surf/${hemi}.7netci
done

### move to native space
for hemi in lh rh;do
mri_vol2vol --mov ${SUBJECTS_DIR}/${subj}/mri/${hemi}_${nNet}netci.mgz --targ ${SUBJECTS_DIR}/${subj}/mri/rawavg.mgz --regheader --o ${SUBJECTS_DIR}/${subj}/mri/${hemi}_${nNet}netci-in-rawavg.nii.gz --no-save-reg
done

#### combine lh , rh
fslmaths ${SUBJECTS_DIR}/${subj}/mri/lh_${nNet}netci-in-rawavg.nii.gz -add ${SUBJECTS_DIR}/${subj}/mri/rh_${nNet}netci-in-rawavg.nii.gz ${SUBJECTS_DIR}/${subj}/mri/${nNet}netci.nii.gz

## remove fsaverage_star
rm -rf ${SUBJECTS_DIR}/fsaverage_star
