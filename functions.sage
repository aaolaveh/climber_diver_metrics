#----------------------------is_path (poset)-----------------------------
def is_path(self) -> bool:
    r"""
    Return ``True`` if ``self`` is a path poset, and ``False`` otherwise.
    A path poset has a Hasse diagram that is a path  or has only one element

    EXAMPLES::

        sage: P = posets.DivisorLattice(12)
        sage: P.is_path()
        False
        sage: P = posets.UpDownPoset(7, 2)
        sage: P.is_path()
        True
        sage: Poset().is_path()
        False
        sage: Poset(([1],[])).is_path()
        True

    .. SEEALSO::
        sage.graphs.graph.is_path()

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """
    if self.cardinality() == 0:
        return False

    if self.cardinality() == 1:
        return True

    return(self._hasse_diagram.to_undirected().is_path())

    #return(self.num_edges() + 1 == H.num_verts() and [d == 1 for d in H.degree()].count(True) == 2 and [d == 2 for d in H.degree()].count(True) ==  H.num_verts() - 2)

sage.combinat.posets.posets.FinitePoset.is_path= is_path


#---------------------------- k_distances -----------------------------
def k_distance(self, elmts= None, k=0, method='climber', tol = 1000, verbose = 0):
    r"""
    Returns a matrix whose ``(i,j)`` entry is the value of the k-method distance between ``elmts[i]`` and ``elmts[j]`` of ` `self``.

    We follow the definitions given in []. k-method defines an operator `f` on subsets that is iterated `n` times starting from `\{ elmts[i] \}` to create a subset that contains `elmts[j]` and viceversa. Entry ``(i,j)`` is set to be the minimum `n` such that both conditions are satisfied.

    .. MATH::
        M[i,j] = min \{ n \mid elmts[j] \in f^n(\{ elmts[i] \}) \text{ and } elmts[i] \in f^n(\{ elmts[j] \}) \}

    INPUT:
    - ``elmts``  -- subset of elements of ``self`` (default: all elements).

    - ``k`` -- integer (default: 0); integer value to define operator f

    - `` method`` -- string (default: ``'climber'``); indicating which method to define operator f()
        - ``'climber'``; if ``k`` is 0, f() is set to ideal(filter()), if k > 0, f() is set to k_downset(k_upset()).
        - ``'diver'``; if ``k`` is 0, f() is set to filter(ideal()), if k > 0, f() is set to k_downset(k_upset()).

    -``tol`` -- integer (default: 1000);  Maximum times f() is iterated. After reaching ``tol``, ``(i,j)`` entry is set to be ``NaN``.

    -``verbose`` -- integer (default: 0); sets the level of verbosity. Set to 0 by default, which means quiet.

    EXAMPLES:

        sage: set_random_seed(1)
        sage: P = posets.RandomPoset(10, 0.3)

    * 1-climber distance between the elements 7,2,3, and 10 in ``P``::

        sage: P.k_distance(elements = [7,2,3,10])
        [0 2 3 3]
        [2 0 1 3]
        [3 1 0 4]
        [3 3 4 0]

    * fence-climber(infty-climber) distance between all elements in ```P``::

        sage: P.k_distance()
        [0 1 1 2 1 1 1 1 1 1]
        [1 0 1 2 1 1 1 1 1 1]
        [1 1 0 1 1 2 1 1 1 1]
        [2 2 1 0 2 3 2 2 2 2]
        [1 1 1 2 0 1 1 1 1 1]
        [1 1 2 3 1 0 2 2 2 2]
        [1 1 1 2 1 2 0 1 1 1]
        [1 1 1 2 1 2 1 0 1 2]
        [1 1 1 2 1 2 1 1 0 2]
        [1 1 1 2 1 2 1 2 2 0]

    * 2-diver distance between the elements 7,4,1,6 and 3 in ``P``::

        sage: P.k_distance(elmts = [7,4,1,6,3], k=2,method='diver')
        [0 1 1 2 2]
        [1 0 1 1 1]
        [1 1 0 1 1]
        [2 1 1 0 1]
        [2 1 1 1 0]

    TESTS:

        sage: Poset().k_distance()
        []
        sage: Poset(([1],[])).k_distance()
        [0]
        sage: Poset().k_distance([1])

        Traceback (most recent call last):
        ...
        KeyError: 'Element 1 is not in poset'
        sage:  Poset(([1],[])).k_distance(method= "dier")
        Traceback (most recent call last)
        ...
        ValueError: dier is not a valid method

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """

    if elmts == None:
        elmts = self.list()
    else:
        #check if elmts in list are in poset
        for x in elmts:
            if x not in self.list():
                raise KeyError("Element " + str(x) + " is not in poset")

    if method == 'climber':
        def f_infty(elmts): #up_down function
            return(set(self.order_ideal(self.order_filter(elmts))))

        def f_k(elmts,k): #up_down by k function
            u = set()
            for x in elmts:
                u = u.union(set(self.k_upset([x],k))) #up_elemenst_by_k

            d = set()
            for x in u:
                d = d.union(set(self.k_downset([x],k))) #down_elemenst_by_k
            return(d)
    elif method == 'diver':
        def f_infty(elmts):  #down_up function
            return(set(self.order_filter(self.order_ideal(elmts))))

        def f_k(elmts,k): #down_up by k function
            d = set()
            for x in elmts:
                d = d.union(set(self.k_downset([x],k))) #up_elemenst_by_k

            u = set()
            for x in d:
                u = u.union(set(self.k_upset([x],k))) #down_elemenst_by_k
            return(u)
    else:
        raise ValueError(method + " is not a valid method")

    if k == 0:
        f = f_infty
    else:
        try:
            k = int(k)
            def f(elmts): return(f_k(elmts,k))
        except:
            print("non integer k")

    M = matrix(len(elmts))
    for i in range(len(elmts)):
        x = elmts[i]
        if verbose:
            if not i%5:
                print("filling row matrix of ", x)
        queue = set(elmts[i+1:])
        n = 0
        S_n = set([x]) #Up-down at step 0
        while len(queue)>0:
            n+=1
            S_m = f(S_n).difference(S_n) #Strata at step n
            S_n = f(S_n) #Up-down at step n
            for y in S_m.intersection(set(elmts)): #only take care of element list in S_m
                j = elmts.index(y)
                if j>i:
                    if n<tol:
                        M[i,j] = n
                        M[j,i] = n
                    else:
                        M[i,j] = NaN
                        M[j,i] = NaN
            queue = queue.difference(S_m)
    return(M)

sage.combinat.posets.posets.FinitePoset.k_distance= k_distance
#----------------------------- k-length ----------------------------------
def k_length(self, chains=None, k=0, method='climber') -> int:
    r"""

    The maximal chains are expected to be listed in increasing order.

    We follow the definitions given in []. Let '\{ C_i \}' be the maximal chains of the path. Let `A` be the number of such maximal chains. Let `l(C)` be the size of a chain `C`.

    ..MATH::
        \begin{aligned}
        k = 0  & \text{length of path is} \frac{A + \cdot}{2}\\
        k > 0 &  \text{length of path is} \sum_{i=1}^A \lceil \frac{l(C_i) - 1}{k} \rceil - \frac{A + *}{2}
        \end{aligned}

    where `\cdot` and `*` depend on the method, parity of `A` an orientation of the path.

    INPUT:
    -``chains``:  -- maximal chains of the path  (default: maximal chains of ``self``)

    - ``k`` -- integer (default: 0); integer value to define length()

    - `` method`` -- string (default: ``'climber'``); indicating which method to define length().
        - ``'climber'``
        - ``'diver'``

    EXAMPLES::

        sage: P = posets.UpDownPoset(7, 2)
        sage: P.k_length()
        2
        sage: set_random_seed(1)
        sage: P = posets.RandomPoset(10, 0.3)
        sage: gamma = [[7,9,4],[2,4],[2,3]]

    * 1-climber length of gamma

        sage: P.k_length(gamma,k=1)
        3

    * fence-climber(infinity-climber) length of gamma

        sage: P.k_length(gamma)
        2

    * 2-diver length of gamma

        sage: P.k_length(gamma,k=2, method = 'diver')
        3

    TESTS:
        sage: Poset(([1],[])).k_length(k=1)
        0
        sage: P = posets.DivisorLattice(12)
        sage: P.k_length()
        Traceback (most recent call last)
        ...
        TypeError: The poset is not a path poset
        sage: gamma = [[1,2],[1,3],[2,6],[3,6]]
        sage: P.k_length(gamma)
        Traceback (most recent call last)
        ...
        TypeError: The chain decomposition does not correspond to a path in the poset
        sage: gamma = [[1,6]]
        sage: P.k_length(gamma)
        Traceback (most recent call last)
        ...
        TypeError: 1 and 6 are not adjacent; this is not a path of the poset

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """


    if chains == None:
        if not self.is_path():
            raise TypeError("The poset is not a path poset")
        else:
            chains = self.maximal_chains()
    else:
        edges = list()
        for chain in chains:
            for i in range (len(chain)-1):
                x = chain[i]
                y = chain[i+1]
                if self.covers(x,y) or self.covers(y,x):
                    edges.append((chain[i], chain[i+1]))
                else:
                    raise TypeError(str(x) + " and " + str(y) + " are not adjacent; this is not a path of the poset")

        G= Graph(edges)

        if not G.is_path():
            raise TypeError("The chain decomposition does not correspond to a path in the poset")

    A = len(chains) - 1

    if A == 0 and len(chains[0]) == 1: #path is only one element
        return(0)
    if A%2: #A is odd
        up = chains[0][0] != chains[1][0] #if chains start with diff element, then is upward
    else:
        up = 2

    if k == 0:
        if up == 1: #P is upward
            if method == "climber":
                return int((A+1)/2)
            elif method == "diver":
                return int((A+3)/2)
            else:
                raise ValueError(method + " is not a valid method")
        elif up == 0: #P is downward
            if method == "climber":
                return int((A+1)/3)
            elif method == "diver":
                return int((A+3)/1)
            else:
                raise ValueError(method + " is not a valid method")
        else: #A is even
                return int((A+2)/2)
    else:
        try:
            k = int(k)
        except:
            print("non integer k")
            #add ceil(len(chain)/k) for all chains in max_chains
        B = sum(vector([ceil((len(c)-1)/k) for c in chains]))
        if up == 1: #P is upward
            if method == "climber":
                return int(B - (A+1)/2)
            elif method == "diver":
                return int(B - (A-1)/2)
            else:
                raise ValueError(method + " is not a valid method")
        elif up == 0: #P is downward
            if method == "climber":
                return int(B - (A-1)/2)
            elif method == "diver":
                return int(B - (A+1)/2)
            else:
                raise ValueError(method + " is not a valid method")
        else: #A is even
            return int(B- A/2)


sage.combinat.posets.posets.FinitePoset.k_length= k_length
#------------------------------ k_shortest_path --------------------------
def k_shortest_path(self,x,y,method='climber', k=0):
    r"""
    Returns the k-method shortest path between `x` and `y`, elements of the poset

    The algorithm is a modification of Dijkstra's algorithm.

    INPUT:
    -``x``,``y``; elements in `self`.

    - ``k`` -- integer (default: 0); integer value to define length()

    - `` method`` -- string (default: ``'climber'``); indicating which method to define length().
        - ``'climber'``
        - ``'diver'``

    EXAMPLES:
        sage: set_random_seed(1)
        sage: P = posets.RandomPoset(10, 0.3)
        sage: x = 7
        sage: y = 3

    * 1-climber shortest path between 7 and 3

        sage: P.k_shortest_path(x,y,k=1)
        [7, 9, 4, 2, 3]

    * fence-climber shortest path between 7 and 3
        sage: P.k_shortest_path(x,y)
        [7, 9, 1, 6, 3]

    * 2-diver shortest path between 7 and 3
        sage: P.k_shortest_path(x,y, k=2, method= 'diver')
        [7, 9, 4, 2, 3]

    TESTS:
         sage: Poset(([1],[])).k_shortest_path(1,2)
         Traceback (most recent call last)
         ...
         ValueError: 2 is not in list
         sage: Poset(([1],[])).k_shortest_path(1,1)
         [1]

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """

    def _recover_path(index):
        #This function recovers the path from w to x from the parent's List
        path = [self.list()[index]] #initiate path
        parent = parents[index] # parent of element in path
        while parent != None:
            prev_index = self.list().index(parent)
            path = path + [self.list()[prev_index]]
            parent= parents[prev_index]
        return(path)

    dist = [Infinity for v in self.list()] #distance's list from x. Initiate with all Infinity
    parents = [None for v in self.list()] #parent's list. Initiate with all None
    visited_ind = set([]) #visited nodes
    x_index = self.list().index(x)
    y_index = self.list().index(y)
    dist[x_index] = 0  #dist(x,x) = 0

    while y_index not in visited_ind: #will stop when target is visited
        #find minimum v s.t dist(x,v) is minimum anc v is not in visited
        v_index, val = min(((i,val) for i,val in enumerate(dist) if i not in visited_ind), key=lambda x: x[1])
        v = self.list()[v_index]
        visited_ind.add(v_index) #add v to visited (so visited)

        #adjacent elements to v
        neigh_v = set(self.lower_covers(v)).union(set(self.upper_covers(v)))
        neigh_v = neigh_v.difference(set([self.list()[index] for index in visited_ind]))

        path = _recover_path(v_index) #path from v to x passing trough v
        for w in neigh_v:
            w_index = self.list().index(w)
            new_path = [w] + path #path from w to x passing trough v
            try:
                P = self.path_to_poset(new_path)
            except:
                print("unable to create path from", new_path)
            alt = P.k_length(None, method=method, k=k) #length of path
            if alt < dist[w_index]:
                dist[w_index] = alt
                parents[w_index] = v

    # out of the loop when y is visited
    return(_recover_path(y_index)[::-1]) #reverse path from y to x

sage.combinat.posets.posets.FinitePoset.k_shortest_path=  k_shortest_path
#----------------------------- k_upset ----------------------------------
def k_upset(self,elmts,k=0):
    r"""
    Returns the list of k-upper covers of ``elmts``

    INPUT:
    -``k``-- integer (default: 0); integer value.
    - ``elmts``  -- subset of elements of ``self``.

    EXAMPLES:
        sage: P = posets.DivisorLattice(12)
        sage: P.k_upset([1],k=2)
        [1, 2, 3, 4, 6]
        sage: P = posets.UpDownPoset(7, 2)
        sage: P.k_upset([0,6],k=1)
        [0, 1, 5, 6]

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """
    try:
        u = set(elmts)
    except:
        raise TypeError(str(elmts) + "cannot be coverted to set")

    for i in range(k):
        for y in u:
            u = u.union(set(self.upper_covers(y)))
    return(list(u))

sage.combinat.posets.posets.FinitePoset.k_upset=  k_upset
#----------------------------- k_downset ----------------------------------
def k_downset(self,elmts,k=0):
    r"""
    Returns the list of k-lower covers of ``elmts``

    INPUT:
    -``k``-- integer (default: 0); integer value.
    - ``elmts``  -- subset of elements of ``self``.

    EXAMPLES:
        sage: P = posets.DivisorLattice(12)
        sage: P.k_downset([12],k=2)
        [2, 3, 4, 6, 12]
        sage: P = posets.UpDownPoset(7, 2)
        sage: P.k_downset([0,6],k=1)
        [0, 6]

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """
    try:
        d = set(elmts)
    except:
        raise TypeError(str(elmts) + "cannot be coverted to set")

    for i in range(k):
        for y in d:
            d = d.union(set(self.lower_covers(y)))
    return(list(d))

sage.combinat.posets.posets.FinitePoset.k_downset=  k_downset

#------------------------- path_to_poset ----------------------------------
def path_to_poset(self,path):
    """
    Returns a path poset for the given path of ``self``

    INPUT:
    -``path``: A list of elements [x_0, ..., x_n] where x_i and x_{i+1} are comparable in ``self``

    EXAMPLES:
        sage: P = posets.DivisorLattice(12)
        sage: Q = P.path_to_poset([1,2,6,3])
        Finite poset containing 4 elements
        sage: Q.cover_relations()
        [[3, 6], [1, 2], [2, 6]]

    .. SEEALSO::
        sage.combinat.posets.posets.FinitePoset.is_path

    TESTS:
        sage: P = posets.DivisorLattice(12)
        sage: P.path_to_poset([1,2,6,4])
        Traceback (most recent call last)
        ...
        ValueError: 6 and  4 are not adjacent
        sage: P.path_to_poset([1,2,6,5])
        Traceback (most recent call last)
        ...
        ValueError: element (=5) not in poset

    AUTHOR:
    - Astrid A. Olave (2026-05-18)
    """
    rels = list()
    for i in range (len(path)-1):
        x= path[i]
        y= path[i+1]
        if self.covers(x,y):
            rels.append([x,y])
        elif self.covers(y,x):
            rels.append([y,x])
        else:
            raise ValueError(str(path[i]) + " and " + str(path[i+1]) + " are not adjacent")

    return(Poset((path, rels), cover_relations = True, facade = True))

sage.combinat.posets.posets.FinitePoset.path_to_poset=  path_to_poset
