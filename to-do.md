Algorithm 3 process minibatch routine
Input: mini-batch B
for each trainer Ti in trainers T do in parallel
   for each instance J in Ti.instances do 
      votes[i,j] ← Ti.classify(B[j])
      k ← poisson(λ)
      W_inst ← j ∗ k
      Ti.train on instance(W inst)
   end for
   if change detected then
      reset classifier
   end if
end for
E.compile(votes)
B.clear()
