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
	REPLACEMENT=\".\*\[1-3\]\[B-H\].\*\$\|.\*\[4-6\]\[A-H\].\*\$\"
elif [ $FC = Ah2 ]; then
	REPLACEMENT=\".\*\[1-3\]\[A-H\].\*\$\|.\*\[4-6\]\[B-H\].\*\$\"
elif [ $FC = Bh1 ]; then
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[4-6\]\[B\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = Bh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A\].\*\$\|.\*\[1-3\]\[B\].\*\$\|.\*\[1-6\]\[C-H\].\*\$\"
elif [ $FC = Ch1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[4-6\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Ch2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-B\].\*\$\|.\*\[1-3\]\[C\].\*\$\|.\*\[1-6\]\[D-H\].\*\$\"
elif [ $FC = Dh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[4-6\]\[D\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = Dh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-C\].\*\$\|.\*\[1-3\]\[D\].\*\$\|.\*\[1-6\]\[E-H\].\*\$\"
elif [ $FC = Eh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[4-6\]\[E\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = Eh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-D\].\*\$\|.\*\[1-3\]\[E\].\*\$\|.\*\[1-6\]\[F-H\].\*\$\"
elif [ $FC = Fh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[4-6\]\[F\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = Fh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-E\].\*\$\|.\*\[1-3\]\[F\].\*\$\|.\*\[1-6\]\[G-H\].\*\$\"
elif [ $FC = Gh1 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[4-6\]\[G\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = Gh2 ]; then                   
	REPLACEMENT=\".\*\[1-6\]\[A-F\].\*\$\|.\*\[1-3\]\[G\].\*\$\|.\*\[1-6\]\[H\].\*\$\"
elif [ $FC = Hh1 ]; then                   
	REPLACEMENT=\".\*\[1-3\]\[A-G\].\*\$\|.\*\[4-6\]\[A-H\].\*\$\"
elif [ $FC = Hh2 ]; then                   
	REPLACEMENT=\".\*\[1-3\]\[A-H\].\*\$\|.\*\[4-6\]\[A-G\].\*\$\"
fi

if [ $FC = "complete" ]; then
	sed -i "s/-x \".\*\[1-6\]\[B-H\].\*\$\"//g" $PROJECT_DIR/guppy_mm2/run_basecalling.sh
else
	sed -i "s/\".\*\[1-6\]\[B-H\].\*\$\"/$REPLACEMENT/g" $PROJECT_DIR/guppy_mm2/run_basecalling.sh
fi
