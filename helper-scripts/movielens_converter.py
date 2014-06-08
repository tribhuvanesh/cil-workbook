__author__ = 'Tribhuvanesh'

import numpy as np
from scipy.io import savemat

MOVIE_LENS_DATA_PATH = 'ml-100k/u.data'
MOVIE_LENS_OUT_PATH = 'ml-100k.mat'
DELIMITER = None  # Use none otherwise
NIL = 99

ENABLE_SCALE = True
# Eliminate rows and columns which have no information
ENABLE_ZILCH_FILTER = True


def main():
    raw_mat = np.loadtxt(MOVIE_LENS_DATA_PATH, dtype=int, delimiter=DELIMITER)
    users_set = set(raw_mat[:, 0])
    items_set = set(raw_mat[:, 1])

    num_users = max(users_set)
    num_items = max(items_set)

    ratings_mat = np.zeros((num_users, num_items), dtype=float)
    ratings_mat.fill(NIL)

    for user_id, item_id, rating, timestamp in raw_mat:
        if ENABLE_SCALE:
            ratings_mat[user_id-1, item_id-1] = (rating - 3.0)*5.0
        else:
            # Scale the values between -10. and +10.
            ratings_mat[user_id-1, item_id-1] = rating

    savemat(MOVIE_LENS_OUT_PATH, dict(X=ratings_mat))

    print 'Completed dump of %d-by-%d ratings matrix' % (num_users, num_items)


if __name__ == "__main__":
    main()