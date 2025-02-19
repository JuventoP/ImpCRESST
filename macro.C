#include <TFile.h>
#include <TTree.h>
#include <TH1F.h>
#include <iostream>
#include <string.h>

using namespace impCresst::dataRecord::containers;

//change lines 78, 82, 85, 86 to include weights

void readImpCresstFile(std::string fileName) {
	//Open the ImpCresst file with the given name in read-only mode
	TFile *f = TFile::Open(fileName.c_str(), "READ");
	std::cout << "Process file: " << f->GetName() << " ..." << std::endl;
	TTree *tree = nullptr;
	//Access the TTree with name "Tree" inside the file
	f->GetObject("Tree", tree);
	if(!tree) {
		std::cerr << "Could not find Tree." << std::endl;
		return;
	}
	//Set a pointer of type impCresst::dataRecord::containers::Event
	//to the branch "Event" of the TTree
	Event *event = nullptr;
	tree->SetBranchAddress("Event", &event);

	//Create an output file to store the results of this script
	//The name is the same as the ImpCresst files plus the suffix "_proc"
	TString outName = f->GetName();
	outName = outName.Insert(outName.Length()-5,"_proc");
	TFile *fOut = TFile::Open(outName,"RECREATE");
	if(!fOut) {
		std::cerr << "Could not create: " << outName << std::endl;
		return;
	}
	std::cout << "Open output file: " << fOut->GetName() << std::endl;
	//Create a TTree in the output file to store ...
	TTree *tOut = new TTree("Tree","Processed data");
	tOut->SetDirectory(fOut);
	//... the hitTime data ...
	Double_t time = 0.;
    Double_t weight = 0.;
	tOut->Branch("time", &time);
    //tOut->Branch("weight", &weight);
	//... and a histogram of the energy deposits
	constexpr double minX = 0.;      //Lower histogram edge at 0. MeV
	constexpr double maxX = 0.015;     //Upper edge at 10. MeV
	constexpr int nbBinsX = 100;//With 1e7 bins -> bin width of 10MeV/1e7=1eV
	TH1D *hEnergy = new TH1D("hEnergy", "Energy deposition per hit", nbBinsX, minX, maxX);
	hEnergy->SetDirectory(fOut);
	hEnergy->GetXaxis()->SetTitle("Energy / MeV");
	hEnergy->GetYaxis()->SetTitle("Counts");

	std::string csvFileName = fileName.substr(0, fileName.find_last_of('.')) + ".csv";
    std::ofstream csvFile;
    csvFile.open(csvFileName, std::ios::out | std::ios::app);
    csvFile << "EnergyDeposit,HitTime,StepWeight\n";

	//Loop over all entries of the TTree
	//in each iteration, the event pointer points to the value of the
	//branch "Event" for the current entry
	for(long int i = 0; i < tree->GetEntries(); ++i) {
		//Info printout
		if(i%1000 == 0) {
			std::cout << "Event " << i << std::endl;
		}
		//Get current entry
		tree->GetEntry(i);

		//Get the 0-th detector
		//Adapt this if you want another detector or if you want to loop over all detectors or ...
		const Detector* detector = event->GetDetector(0);
		//Loop over all hits of the detector ...
		for(const auto* hit : detector->GetHits()) {
			//... and get the energy deposition and time of the current hit
			Double_t myEnergy = hit->GetEnergyDeposit();
			Double_t myTime = hit->GetHitTime();
            Double_t myWeight = hit->GetStepWeight();
			//Fill the time in the TTree of the output file
			time = myTime;
			tOut->Fill();
            weight = myWeight;
			tOut->Fill();
			//Fill the energy in the histogram
			hEnergy->Fill(myEnergy, myWeight);
            csvFile << myEnergy << "," << myTime << "," << myWeight << "\n";
		}
	}
    std::cout << "Writing to csv file: " << csvFileName << std::endl;
    csvFile.close();
	//Write the output file and close it
	fOut->Write();
	fOut->Close();
	//Close the impCresst file
	f->Close();
}

