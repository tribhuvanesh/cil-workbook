__author__ = 'Tribhuvanesh'

import numpy as np
from scipy.io import savemat

MOVIE_LENS_DATA_PATH = 'ml-1m/ratings.dat'
MOVIE_LENS_OUT_PATH = 'ml-1m.mat'
DELIMITER = '::'  # Use none otherwise
NIL = 99


def main():
    raw_mat = np.loadtxt(MOVIE_LENS_DATA_PATH, dtype=int, delimiter=DELIMITER)
    users_set = set(raw_mat[:, 0])
    items_set = set(raw_mat[:, 1])

    num_users = max(users_set)
    num_items = max(items_set)

    ratings_mat = np.zeros((num_users, num_items), dtype=int)
    ratings_mat.fill(NIL)

    for user_id, item_id, rating, timestamp in raw_mat:
        ratings_mat[user_id-1, item_id-1] = rating

    savemat(MOVIE_LENS_OUT_PATH, dict(X=ratings_mat))

    print 'Completed dump of %d-by-%d ratings matrix' % (num_users, num_items)


if __name__ == "__main__":
    main()