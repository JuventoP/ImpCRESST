# I used a jupyter notebook to implement the following but the codes are the same
# # Here primaries means events and repetitions means runs

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

if __name__=="__main__":
    dir = '/afsuser/praveen/silo2/simulation/ImpCRESST/data/hitsVprim/0_bias_20_rep_shielded/' # Directory of my csv files
    prim = np.arange(10, 110, 10)
    rep = np.arange(1, 21, 1)
    hits = np.zeros((len(prim), len(rep)))
    for i, p in enumerate(prim):
        for j, r in enumerate(rep):
            data_file = pd.read_csv(dir+str(p)+'_'+str(r)+'.csv')
            hits[i][j] = len(data_file['EnergyDeposit'])

    hits_mean = []
    hits_std = []
    for i in range(len(hits)):
        arr = np.array([x for x in hits[i] if x != 0])
        hits_mean.append(arr.mean())
        hits_std.append(arr.std())

    plt.errorbar(prim, hits_mean, yerr=hits_std, capsize=5, marker='o')
    plt.ylabel('hits')
    plt.xlabel('primaries')
    plt.savefig(dir+'hitsVprim.png', bbox_inches='tight')

    plt.plot(prim, hits_mean/prim)
    plt.ylabel('hits per primary')
    plt.xlabel('primaries')
    plt.savefig(dir+'hits_per_primVprim.png', bbox_inches='tight')