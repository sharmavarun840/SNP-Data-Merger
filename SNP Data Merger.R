#700604 SNPs 700 individuals in data##

sort -k3n mydata.bim |  uniq  -f2 -D | cut -f2 > dupeSNP.txt 


plink2 --bfile mydata --exclude dupeSNP.txt --make-bed --out mydata_clean 

#tw different parameters for Qc of data
plink --bfile mydata_clean --mind 0.1 --geno 0.1 --maf 0.01 --make-bed --out mydataclean1


plink --bfile mydataclean1 --mind 0.1 --geno 0.1 --maf 0.05 --make-bed --out mydata_Clean


##to change genetic distance in centi morgans
awk -v FS='[[:space:]]+' 'BEGIN{OFS="\t"} {$3="0";$1=$1} 1' mydata_Clean.bim > mydata_Clean2.bim

#3to change 6th column in the fam file 
awk '{$6=1 ; print ;}' mydata_Clean.fam > mydata_Clean2.fam

# to modify bim file snp Ids 
awk '{$2 = $1"_"$4; print}' mydata_Clean2.bim > mydata_Clean2.bim


#finding common SNPs in two different datasets
awk '{print $2}' mydata_duprmv.bim | sort > mydata.txt

awk '{print $2}' data2.bim | sort > data2.txt

comm -12 mydata.txt data2.txt > commonsnps.txt

#I am using bfiles with first Qc### 

#extract common SNPs from SMVDU samples
plink2 --bfile mydata_qc --extract COMMON1.txt --make-bed --out mydata_common


#extract common SNPs from dataset2 samples
plink2 --bfile dataset2 --extract COMMON1.txt --make-bed --out dataset2_common
#319532 variants remaining after main filters, 4605 individuals

#merge the binary files
plink --bfile mydata_common --bmerge dataset2.bed dataset2.bim dataset2.fam --make-bed --out mydata_dataset2_comm 


#got error and a .misssnp file was made, when tried to flp it there were duplicates in the mydata file remobed them
cut -f 2 mydata_common.bim | sort | uniq -d > 1.dups
plink --bfile mydata_common  --exclude 1.dups --make-bed --out mydata_dataset2_common

#then flipped
plink --bfile mydata_dataset2_common --flip ------.missnp --make-bed --out mydata_commonflipped

#merged again
plink --bfile mydata_commonflipped --bmerge dataset2_common.bed dataset2_common.bim dataset2_common.fam --make-bed --out mydata_datase2_comm_1

#excluded .missnp
plink --bfile mydata_commonflliped -
  -exclude filename-merge.missnp --make-bed --out mydata_flipped2

##merged again
plink --bfile mydata_flipped2 --bmerge dataset2_common.bed dataset2_common.bim dataset2_common.fam --make-bed --out mydata_dataset2Common

#qc of merged data
plink --bfile mydata_dataset2Common --mind 0.1 --geno 0.1 --maf 0.01 --make-bed --out mydata_dataset2_clean


##LD pruning#
plink --bfile mydata_dataset2Common --indep-pairwise 50 10 0.5 --out mydata_dataset2Common_Pruned


plink --bfile mydata_dataset2Common_Pruned --extract filename.prune.in --make-bed --out mydata_dataset2_clean


plink --bfile mydata_dataset2_clean --extract JK_Globalpruned.prune.in --make-bed --out JK_Global_Pruned --allow-no-sex

