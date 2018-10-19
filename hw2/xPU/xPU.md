# xPU

## Tensor Pro​cessing Unit (TPU)
Vendor: Google.  

Type: Neural processor.  

Example:  
* Reducing word error rates in speech recognition by 30% over traditional approaches.
* Cutting the error rate in an image recognition competition since 2011 from 26% to 3.5%.
* AlphaGo.

### Feature  

The heart of the TPU is a 65,536 8-bit MAC matrix multiply unit that offers a peak throughput of 92 TeraOps/second (TOPS) and a large (28 MiB) software-managed on-chip memory.

### Pros

* The TPU’s deterministic execution model is a better match to the 99th-percentile response-time requirement of our NN applications. 

* The TPU has 25 times as many MACs and 3.5 times as much on-chip memory as the K80 GPU.

* The TPU is on average about 15X - 30X faster than its contemporary GPU or CPU, with TOPS/Watt about 30X - 80X higher.

* The performance/Watt of the TPU is 30X - 80X that of contemporary products; the revised TPU with K80 memory would be 70X - 200X better.

* The TPU has the lowest power—118W per die total (​TPU+Haswell/2​) and 40W per die incremental.

### Cons

* Lower memory bandwidth: Four of the six NN apps are memory-bandwidth limited on the TPU.

* The TPU has poor energy proportionality: at 10% load, the TPU uses 88% of the power it uses at 100%. 

* Architects have neglected important NN tasks.

* For NN hardware, Inferences Per Second (IPS) is an inaccurate summary performance metric.

* Performance counters added as an afterthought for NN hardware.

### Indicators

#### Rooflines, Response-Time, and Throughput
The Y-axis is performance in floating-point operations per second, thus the peak computation rate forms the “flat” part of the roofline. The X-axis is operational intensity, measured as floating-point operations per DRAM byte accessed.
![rootline](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/roofline.png)


#### Cost-Performance, TCO, and Performance/Watt
The TPU server has 17 to 34 times better total-performance/Watt than Haswell, which makes the TPU server 14 to 16 times the performance/Watt of the K80 server.
![performance/watt](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/performance%3Awatt.png)

#### Energy Proportionality
The TPU has the lowest power—118W per die total(​TPU+Haswell/2​) and 40W per die incremental — but it has poor energy proportionality: at 10% load, the TPU uses 88% of the power it uses at 100%.
Haswell is the best at energy proportionality of the group: it uses 56% of the power at 10% load as it does at 100%. 
The K80 is closer to the CPU than the TPU, using 66% of the full load power at 10% workload.


[References]: In-Datacenter Performance Analysis of a Tensor Processing Unit.


## Intelligence Processing Unit （IPU）
Vendor: Graphcore.  

Type: Neural processor.

### Feature
* Designed ground-up for MI, both training and deployment.
* Large 16nm custom chip, cluster-able, 2 per PCIe card.
* Over 1000 truly independent processors per chip; all-to-all non-blocking exchange.
* All model state remains on chip; no directly-attached DRAM.
* Mixed-precision floating-point stochastic arithmetic.

### Pros
* DNN performance well beyond Volta and TPU2; efficient without large batches.
* Unprecedented flexibility for non-DNN models; thrives onn sparsity.


[References]: NIPS 2017‌ P‍R‍ESENTATIONS.


## DianNao
Vendor: Cambricon.  

Type: AI accelerator.

### Feature
An accelerator with a high throughput, capable of performing 452 GOP/s (key NN operations such as synaptic weight multiplications and neurons outputs additions) in a small footprint of 3.02 mm2 and 485 mW; compared to a 128-bit 2GHz SIMD processor, the accelerator is 117.87x faster, and it can reduce the total energy by 21.08x. 

### Pros
* A synthesized (place & route) accelerator design for large-scale CNNs and DNNs, the state-of-the-art machine- learning algorithms.
* The accelerator achieves high throughput in a small area, power and energy footprint.
* The accelerator design focuses on memory behavior, and measurements are not circumscribed to computational tasks, they factor in the performance and energy impact of memory transfers.

### Indicators

#### Time and Throughput
![speedup](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/speedup.png)

#### Energy
![energy-reduction](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/energy-reduction.png)


[References]: DianNao: A Small-Footprint High-Throughput Accelerator for Ubiquitous Machine-Learning.


## Comments



