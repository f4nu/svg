#    rect -l20 0 0 7cm 2cm \
#vpype \
#    pagesize -l 7cmx2cm \
#    read -l1 fanusele/25-novembre-2022.svg \
#    scaleto -l1 -o 0 0 4.5cm 1.5cm \
#    translate -l1 1.2cm 0.5cm \
#    write fanusele/25-nov.out.svg

#vpype read fanusele/fanu.svg layout -l -m 0 1.5cmx0.5cm write fanusele/fanu-out.svg
#vpype read fanusele/and.svg layout -m 0 0.5cmx0.5cm write fanusele/and-out.svg
#vpype read fanusele/sele.svg layout -l -m 0 1.5cmx0.5cm write fanusele/sele-out.svg

#vpype \
#    read -l1 fanusele/enea.svg \
#    scaleto -l1 -o 0 0 3cm 3cm \
#    layout -h center -v center 5.3cmx5.3cm \
#    write fanusele/enea.out.svg


#    rect -l20 0 0 2cm 7cm \
#vpype \
#    pagesize 7cmx2cm \
#    read -m -l1 -c fanusele/fanu.svg \
#    scaleto -l1 -o 0 0 1.5cm 1.5cm \
#    translate -l1 0.15cm 1.2cm \
#    read -m -l2 -c fanusele/and.svg \
#    scaleto -l2 -o 0 0 0.5cm 0.5cm \
#    translate -l2 0.75cm 1.85cm \
#    read -m -l3 -c fanusele/sele.svg \
#    scaleto -l3 -o 0 0 1.5cm 1.5cm \
#    translate -l3 0.15cm 2.5cm \
#    rotate -o 0 0 -- -90 \
#    translate 0 2cm \
#    write fanusele/fanusele.out.svg

NAME=$1
vpype \
    read -m -l1 -c fanusele/$1.svg \
    scaleto -l1 -o 0 0 4.5cm 1.5cm \
    layout -l -v center -h center 9cmx4cm \
    write fanusele/$1.out.svg

./fconv.sh fanusele/$1.out.svg