import unittest
from src.reverse_pc import Space, run, experiment

class SpaceTests(unittest.TestCase):
    def test_two_programs(self):
        result = experiment()
        self.assertTrue(result['distinct'])
        self.assertEqual(result['result_a']['cells'][str(10**80 + 8)], 5)
        self.assertEqual(result['result_b']['cells'][str(10**80 + 8)], 14)
        self.assertEqual(result['allocated_cells_a'], 2)
        self.assertEqual(result['allocated_cells_b'], 2)
        self.assertEqual(result, experiment())

    def test_rollback(self):
        space = Space()
        space.write(10**100, 4)
        original = space.digest()
        with self.assertRaises(ValueError):
            run(space, [{'op':'write','address': 3,'value':8}, {'op':'bad'}])
        self.assertEqual(space.digest(), original)

    def test_implicit_default(self):
        space = Space(default=9)
        self.assertEqual(space.read(10**10000), 9)
        self.assertEqual(len(space.cells), 0)
        space.write(10**10000, 9)
        self.assertEqual(len(space.cells), 0)

    def test_persistent_rule(self):
        space = Space()
        run(space, [{'op':'write','address':1,'value':3},
                    {'op':'connect','a':1,'b':2},
                    {'op':'set_rule','name':'gain','value':5}])
        run(space, [{'op':'propagate','source':1}])
        self.assertEqual(space.read(2), 15)

if __name__ == '__main__':
    unittest.main()
