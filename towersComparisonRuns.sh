#runs to do:

#checkpoint=

time=300
testingTime=300
recSteps=240000 #list repl is roughly 1k/hour (0.33 steps/sec)
ncores=8
#salt=towers
helmRatio=0.5
resume=experimentOutputs/towers1debugContextual

for num in 1 3 20
	do
		resume=experimentOutputs/towers${num}
		salt=towers${num}
		cp ${resume}.pickle ${resume}Sample.pickle
		#Train:
		cmd="python bin/tower.py --contextual --testingTimeout ${testingTime} --recognitionTimeout 216000 --resumeTraining -r ${helmRatio} --primitives new --split 0.5 -t ${time} -RS ${recSteps} --solver python  -c ${ncores} --useValue Sample -i 2 --resume ${resume}Sample.pickle --singleRoundValueEval"
		#eval "${cmd}"
		sbatch -e towersSample${salt}.out -o towersSample${salt}.out execute_gpu_new.sh ${cmd}

		cp ${resume}.pickle ${resume}REPL.pickle
		#Train:
		cmd="python -i bin/tower.py --contextual --testingTimeout ${testingTime} --recognitionTimeout 216000 --resumeTraining -r ${helmRatio} --primitives new --split 0.5 -t ${time} -RS ${recSteps} --solver python  -c ${ncores} --useValue TowerREPL -i 2  --resume ${resume}REPL.pickle --singleRoundValueEval --seed 9"
		om-repeat sbatch -e towersREPL${salt}.out -o towersREPL${salt}.out -p tenenbaum --time=3600 --mem=64G --cpus-per-task=8 --gres=gpu:QUADRORTX6000:1 ${cmd}
		#eval "${cmd}"

		cp ${resume}.pickle ${resume}RNN.pickle
		#Train:
		cmd="python bin/tower.py --contextual --testingTimeout ${testingTime} --recognitionTimeout 216000 --resumeTraining -r ${helmRatio} --primitives new --split 0.5 -t ${time} -RS ${recSteps} --solver python  -c ${ncores} --useValue RNN -i 2 --resume ${resume}RNN.pickle --singleRoundValueEval"
		sbatch -e towersRNN${salt}.out -o towersRNN${salt}.out execute_gpu_new.sh ${cmd}

	done