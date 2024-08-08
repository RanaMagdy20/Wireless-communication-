function     cluster_size_valid = calc_cluster_size(b)   %function choose the suitable value of N.
             k = 1 ;
           
             for i = 0 : 1 : b
                 for j = 1: 1 :b
                      cluster_size_valid(k) = i^2 +j^2+ i*j ;
                      k =k+1 ;
                 end
             end
             t = find(cluster_size_valid >=b) ;
             for i = 1:length(t)
                 h(i) = cluster_size_valid(t(i)) ;
             end
            cluster_size_valid= min (h);
