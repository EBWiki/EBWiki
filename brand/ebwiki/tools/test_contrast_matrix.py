"""Run: python3 -m unittest test_contrast_matrix.py (from this folder)."""
import json, os, tempfile, unittest
import contrast_matrix as cm

class T(unittest.TestCase):
    def test_known_ratios(self):
        # Reference values from WCAG: black on white is 21:1, #767676 on white about 4.54:1.
        self.assertAlmostEqual(cm.contrast((0, 0, 0), (255, 255, 255)), 21.0, places=2)
        self.assertAlmostEqual(cm.contrast(cm.parse_hex("#767676"), (255, 255, 255)), 4.54, places=2)
        self.assertAlmostEqual(cm.contrast(cm.parse_hex("#888"), (255, 255, 255)), 3.54, places=2)

    def test_grades(self):
        self.assertEqual(cm.grade(4.5), "AA")
        self.assertEqual(cm.grade(3.2), "large only")
        self.assertEqual(cm.grade(2.9), "fail")

    def test_simulation_keeps_grays_and_merges_red_green(self):
        g = cm.simulate((128, 128, 128), "deuteranopia")
        self.assertTrue(all(abs(v - 128) < 2 for v in g))
        red, green = cm.parse_hex("#d62728"), cm.parse_hex("#2ca02c")
        self.assertLess(cm.delta_e(cm.simulate(red, "deuteranopia"), cm.simulate(green, "deuteranopia")),
                        cm.delta_e(red, green) / 2)

    def test_end_to_end(self):
        pal = {"name": "Test Site", "colors": [
            {"name": "ink", "hex": "#111111"}, {"name": "paper", "hex": "#ffffff"},
            {"name": "gray", "hex": "#888888"}, {"name": "red", "hex": "#d62728"},
            {"name": "green", "hex": "#2ca02c"}],
            "pairs": [{"fg": "gray", "bg": "paper", "use": "body"},
                      {"fg": "ink", "bg": "paper", "use": "body"}]}
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "p.json")
            with open(p, "w") as fh:
                json.dump(pal, fh)
            files = cm.run(p, d)
            for f in files.values():
                self.assertTrue(os.path.getsize(f) > 0)
            with open(files["contrast.md"]) as fh:
                md = fh.read()
            self.assertIn("gray on paper (body): 3.54:1, needs 4.5:1, FAIL", md)
            self.assertIn("ink on paper (body): 18.88:1, needs 4.5:1, pass", md)
            self.assertIn("red and green look alike", md)
            for ch in ("\u2014", "\u00b7", "|"):
                self.assertNotIn(ch, md)

if __name__ == "__main__":
    unittest.main()
