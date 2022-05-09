Algorithm 3 process minibatch routine   
Input: mini-batch B  
for each trainer Ti in trainers T do in parallel   
&nbsp;&nbsp;&nbsp; for each instance J in Ti.instances do   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      votes[i,j] ← Ti.classify(B[j])   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      k ← poisson(λ)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      W_inst ← j ∗ k  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      Ti.train on instance(W inst)  
&nbsp;&nbsp;&nbsp;   end for  
&nbsp;&nbsp;&nbsp;   if change detected then   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;      reset classifier    
&nbsp;&nbsp;&nbsp;   end if   
end for   
E.compile(votes)  
B.clear()   
