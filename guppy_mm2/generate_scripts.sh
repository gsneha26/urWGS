#!/bin/bash

FC=$(gcloud compute instances describe $(hostname) --zone=$(gcloud compute instances list --filter="name=($(hostname))" --format "value(zone)") --format=value"(metadata[FC])")

REPLAMENT=

if [ $FC = B ]; then
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = C ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = D ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = E ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = F ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = G ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = H ]; then
	REPLACEMENT=\".\*\[1-6\]\[A-G\].\*\$\"
elif [ $FC = Ah1 ]; then
	REPLACEMENT=\".\*\[1-2\]\[B-H\].\*\$\|.\*\[3-6\]\[A-H\].\*\$\"
elif [ $FC = Ah2 ]; then
	REPLACEMENT=\".\*\[1-2\]\[A-H\].\*\$\|.\*\[5-6\]\[B-H\].\*\$\"
elif [ $FC = Ah3 ]; then
	REPLACEMENT=\".\*\[1-4\]\[A-H\].\*\$\|.\*\[5-6\]\[B-H\].\*\$\"
elif [ $FC = Bh1 ]; then
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[3-6\]\[B\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = Bh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[1-2\]\[B\].\*\$\|.\*\[5-6\]\[B\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = Bh3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[1-4\]\[B\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = Ch1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[4-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Ch2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1-2\]\[C\].\*\$\|.\*\[5-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Ch3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1-4\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Dh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[3-6\]\[D\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = Dh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[1-2\]\[D\].\*\$\|.\*\[5-6\]\[D\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = Dh3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[1-4\]\[D\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = Eh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[3-6\]\[E\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = Eh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[1-2\]\[E\].\*\$\|.\*\[5-6\]\[E\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = Eh3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[1-4\]\[E\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = Fh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[3-6\]\[F\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = Fh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[1-2\]\[F\].\*\$\|.\*\[5-6\]\[F\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = Fh3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[1-4\]\[F\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = Gh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[3-6\]\[G\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = Gh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[1-2\]\[G\].\*\$\|.\*\[5-6\]\[G\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = Gh3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[1-4\]\[G\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = Hh1 ]; then                   
	REPLACEMENT=\".\*\[1-3\]\[A-G\].\*\$\|.\*\[3-6\]\[A-H\].\*\$\"
elif [ $FC = Hh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-G\].\*\$\|.\*\[1-2\]\[H\].\*\$\|.\*\[5-6\]\[H\].\*\$\"
elif [ $FC = Hh3 ]; then                   
	REPLACEMENT=\".\*\[1-4\]\[A-H\].\*\$\|.\*\[5-6\]\[A-G\].\*\$\"
elif [ $FC = Ct1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[2-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Ct2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1\]\[C\].\*\$\|.\*\[3-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Ct3 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1-2\]\[C\].\*\$\|.\*\[4-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
fi

if [ $FC = "complete" ]; then
	sed -i "s/-x \".\*\[1-6\]\[B-H\].\*\$\"//g" $PROJECT_DIR/guppy_mm2/run_basecalling.sh
else
	sed -i "s/\".\*\[1-6\]\[B-H\].\*\$\"/$REPLACEMENT/g" $PROJECT_DIR/guppy_mm2/run_basecalling.sh
fi
