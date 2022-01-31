#!/bin/bash
## pythoon_path=<python path> #should have pysam, pybedtools installed. bedtools, samtools should be in the path
python_path=~/anaconda3/bin/python

Rscript_path=<RScript path>
###################################################################
feather=1 #start from feather or run only MAPS
maps=1
number_of_datasets=1
dataset_name=$1
fastq_format=".fastq"
fastq_dir=$2
outdir=$3
macs2_filepath=$4
organism="mm10"
bwa_index=<mm10 bwa index>
bin_size=10000
binning_range=1000000
fdr=2 # this is used just for labeling. do not change
filter_file="None"
generate_hic=1
mapq=30
length_cutoff=1000
threads=54
model="pospoisson" #"negbinom"
sex_chroms_to_process="X"
optical_duplicate_distance=0
####################################################################
###SET THE VARIABLES AT THIS PORTION ONLY IF 
### number_of_datasets > 1 (merging exisitng datasets)
### specify as many datasets as required
####################################################################
dataset1="" 
dataset2="" 
dataset3=""
dataset4=""
#...
##################################################################
###SET THESE VARIABLES ONLY IF FEATHER = 0 AND YOU WANT TO RUN
###USING A SPECIFIC FEATHER OUTPUT RATHER THAN $datasetname_Current
###################################################################
feather_output_symlink=""
##################################################################


DATE=`date '+%Y%m%d_%H%M%S'`
#####Armen:
fastq1=$fastq_dir/$dataset_name"_R1"$fastq_format
fastq2=$fastq_dir/$dataset_name"_R2"$fastq_format
feather_output=$outdir"/feather_output/"$dataset_name"_"$DATE
if [ "$feather_output_symlink" == "" ]; then
        feather_output_symlink=$outdir"/feather_output/"$dataset_name"_current"
fi
resolution=$(bc <<< "$bin_size/1000")
per_chr='True' # set this to zero if you don't want per chromosome output bed and bedpe files
feather_logfile=$feather_output"/"$dataset_name".feather.log"
resolution=$(bc <<< "$bin_size/1000")
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
hic_dir="tempfiles/hic_tempfiles"
if [ $organism == "mm10" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/mm10_chrAll.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.mm10.txt"
        chr_count=19
elif [ $organism == "mm9" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/mm9.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.mm9.txt"
        chr_count=19
elif [ $organism == "hg19" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/hg19.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.hg19.txt"
        chr_count=22
elif [ $organism == "hg38" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.GRCh38.txt"
        chr_count=22
fi

####Ivan:"
if [[ $sex_chroms_to_process != "X" && $sex_chroms_to_process != "Y" && $sex_chroms_to_process != "XY" ]]; then
        sex_chroms_to_process="NA"
        sex_chroms=""
else
        sex_chroms=$sex_chroms_to_process
fi
long_bedpe_dir=$feather_output_symlink"/"
short_bed_dir=$feather_output_symlink"/"
maps_output=$outdir"/MAPS_output/"$dataset_name"_"$DATE"/"
maps_output_symlink=$outdir"/MAPS_output/"$dataset_name"_current"
#genomic_feat_filepath="/home/jurici/MAPS/MAPS_data_files/"$organism"/genomic_features/"$genomic_features_filename





DATE=`date '+%Y%m%d_%H%M%S'`
#####Armen:
fastq1=$fastq_dir/$dataset_name"_R1"$fastq_format
fastq2=$fastq_dir/$dataset_name"_R2"$fastq_format
feather_output=$outdir"/feather_output/"$dataset_name"_"$DATE
if [ "$feather_output_symlink" == "" ]; then
        feather_output_symlink=$outdir"/feather_output/"$dataset_name"_current"
fi
resolution=$(bc <<< "$bin_size/1000")
per_chr='True' # set this to zero if you don't want per chromosome output bed and bedpe files
feather_logfile=$feather_output"/"$dataset_name".feather.log"
resolution=$(bc <<< "$bin_size/1000")
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
hic_dir="tempfiles/hic_tempfiles"
if [ $organism == "mm10" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/mm10_chrAll.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.mm10.txt"
        chr_count=19
elif [ $organism == "mm9" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/mm9.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.mm9.txt"
        chr_count=19
elif [ $organism == "hg19" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/hg19.fa"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.hg19.txt"
        chr_count=22
elif [ $organism == "hg38" ]; then
        if [ -z $bwa_index ]; then
                bwa_index="/home/jurici/MAPS/MAPS_data_files/"$organism"/BWA_index/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta"
        fi
        genomic_feat_filepath=$cwd"/../MAPS_data_files/"$organism"/genomic_features/F_GC_M_MboI_"$resolution"Kb_el.GRCh38.txt"
        chr_count=22
fi

####Ivan:"
if [[ $sex_chroms_to_process != "X" && $sex_chroms_to_process != "Y" && $sex_chroms_to_process != "XY" ]]; then
        sex_chroms_to_process="NA"
        sex_chroms=""
else
        sex_chroms=$sex_chroms_to_process
fi
long_bedpe_dir=$feather_output_symlink"/"
short_bed_dir=$feather_output_symlink"/"
maps_output=$outdir"/MAPS_output/"$dataset_name"_"$DATE"/"
maps_output_symlink=$outdir"/MAPS_output/"$dataset_name"_current"
#genomic_feat_filepath="/home/jurici/MAPS/MAPS_data_files/"$organism"/genomic_features/"$genomic_features_filename

     
if [ $maps -eq 1 ]; then
        mkdir -p $maps_output
        echo "$dataset_name $maps_output $macs2_filepath $genomic_feat_filepath $long_bedpe_dir $short_bed_dir $bin_size $chr_count $maps_output"
        $python_path $cwd/MAPS/make_maps_runfile.py $dataset_name $maps_output $macs2_filepath $genomic_feat_filepath $long_bedpe_dir $short_bed_dir $bin_size $chr_count $maps_output $sex_chroms_to_process --BINNING_RANGE $binning_range
        echo "first"
        $python_path $cwd/MAPS/MAPS.py $maps_output"maps_"$dataset_name".maps"
        echo "second"
        $Rscript_path $cwd/MAPS/MAPS_regression_and_peak_caller.r $maps_output $dataset_name"."$resolution"k" $bin_size $chr_count$sex_chroms $filter_file $model 
        $Rscript_path $cwd/MAPS/MAPS_peak_formatting.r $maps_output $dataset_name"."$resolution"k" $fdr $bin_size
        echo "third"
        cp "$(readlink -f $0)" $maps_output"/execution_script_copy"
        chmod 777 $maps_output
        ln -sfn $maps_output $maps_output_symlink
fi



