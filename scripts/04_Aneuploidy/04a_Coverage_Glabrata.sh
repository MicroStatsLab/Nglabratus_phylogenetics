#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=0
#SBATCH --time=5:00:00
#SBATCH --mem=0
#SBATCH --mail-user=adamubua@myumanitoba.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=BAM_coverage
#SBATCH --output=%x-%j.out

module load picard samtools
module load samtools #if working on the cluster.
cat samples.txt | parallel 'samtools depth -a {}.bam > {}.depth'
cat samples.txt | parallel 'echo -e "Chr\\tlocus\\t{}" | cat - {}.depth > {}.Hbam.txt'
paste *.Hbam.txt | cut -f "$(printf "1,2,3"; for i in $(seq 2 $(ls *.Hbam.txt | wc -l)); do printf ",%d" $((3*i)); done)" > coverage.txt

