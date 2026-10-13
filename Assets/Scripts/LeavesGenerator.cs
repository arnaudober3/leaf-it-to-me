using UnityEngine;
using UnityEngine.Serialization;
using System.Collections.Generic;

public class LeavesGenerator : MonoBehaviour
{
    const float YStart = 6.4f + 0.96f;
    const float SpawnInterval = 3f;
    const int MaxFailedAttempts = 300;
    const float XRangeMin = -3.6f;
    const float XRangeMax = 3.5f;
    const float RotationRangeMin = -1.5f * Mathf.Rad2Deg;
    const float RotationRangeMax = 1.5f * Mathf.Rad2Deg;
    const float YRangeMin = -6.4f;
    const float YRangeMax = 0f;

    static Vector2 XRange = new(XRangeMin, XRangeMax);
    static Vector2 RotationRange = new(RotationRangeMin, RotationRangeMax);
    static Rect InitialPileAreaRect = new(XRangeMin, YRangeMin, XRangeMax - XRangeMin, YRangeMax - YRangeMin);

    // Serialize the leaf prefab so it can be assigned in the inspector
    // Note: Unity can't serialize readonly fields;
    [SerializeField] Leaf prefab;

    static bool IsPolygonInsideArea(Vector2[] polygon, Rect area)
    {
        foreach (Vector2 point in polygon)
        {
            if (!area.Contains(point))
                return false;
        }

        return true;
    }

    static Vector2[] TransformPolygon(Vector2[] polygon, Vector2 pos, float rotDegrees)
    {
        var result = new Vector2[polygon.Length];
        Quaternion rotation = Quaternion.Euler(0f, 0f, rotDegrees);

        for (int i = 0; i < polygon.Length; i++)
        {
            result[i] = pos + (Vector2)(rotation * polygon[i]);
        }

        return result;
    }

    static bool IsCandidateOverlappingExistingPolygon(Vector2[] candidate, List<Vector2[]> existingPolygons)
    {
        foreach (Vector2[] placed in existingPolygons)
        {
            if (ArePolygonsOverlapping(candidate, placed))
            {
                return true;
            }
        }

        return false;
    }

    static bool ArePolygonsOverlapping(Vector2[] polygonA, Vector2[] polygonB)
    {
        for (int i = 0; i < polygonA.Length; i++)
        {
            Vector2 a1 = polygonA[i], a2 = polygonA[(i + 1) % polygonA.Length];

            for (int j = 0; j < polygonB.Length; j++)
            {
                if (DoSegmentsIntersect(a1, a2, polygonB[j], polygonB[(j + 1) % polygonB.Length]))
                {
                    return true;
                }
            }
        }

        // No overlap of edges.
        // Only remaining overlap is if polygons are fully inside each other
        return IsPointInsidePolygon(polygonA, polygonB[0]) || IsPointInsidePolygon(polygonB, polygonA[0]);
    }

    static float Cross(Vector2 vectorA, Vector2 vectorB) => vectorA.x * vectorB.y - vectorA.y * vectorB.x;
    static bool DoSegmentsIntersect(Vector2 lineAStart, Vector2 lineAEnd, Vector2 lineBStart, Vector2 lineBEnd)
    {
        float AStartSideOfB = Cross(lineBEnd - lineBStart, lineAStart - lineBStart);
        float AEndSideOfB = Cross(lineBEnd - lineBStart, lineAEnd - lineBStart);
        float BStartSideOfA = Cross(lineAEnd - lineAStart, lineBStart - lineAStart);
        float BEndSideOfA = Cross(lineAEnd - lineAStart, lineBEnd - lineAStart);

        bool AOverlapsB = (AStartSideOfB > 0f) != (AEndSideOfB > 0f);
        bool BOverlapsA = (BStartSideOfA > 0f) != (BEndSideOfA > 0f);

        return AOverlapsB && BOverlapsA;

    }

    static bool IsPointInsidePolygon(Vector2[] polygon, Vector2 point)
    {
        bool inside = false;

        for (int i = 0, j = polygon.Length - 1; i < polygon.Length; j = i++)
        {
            bool intersectionY = (polygon[i].y > point.y) != (polygon[j].y > point.y);
            bool intersectionX = point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x;
            if (intersectionY && intersectionX)
            {
                inside = !inside;
            }
        }

        return inside;
    }

    void Start()
    {
        CreateInitialLeaves();
        // Start spawning leaves at regular intervals
        InvokeRepeating(nameof(Instanciate), SpawnInterval, SpawnInterval);
    }

    void Instanciate()
    {
        // Determine a random position and rotation for the new leaf
        var position = new Vector2(Random.Range(XRange.x, XRange.y), YStart);
        float rotation = Random.Range(RotationRange.x, RotationRange.y);
        Spawn(position, rotation);
    }

    void Spawn(Vector2 position, float rotation)
    {
        Leaf leaf = Instantiate(prefab, position, Quaternion.Euler(0f, 0f, rotation), transform);
        // Leaf starts to fall down the screen
        leaf.Animate();
    }

    // Randomly places non-overlapping leaves at the bottom of the screen until area is full
    void CreateInitialLeaves()
    {
        Vector2[] shape = prefab.GetComponent<PolygonCollider2D>().points;
        var placedLeaves = new List<Vector2[]>();
        int failures = 0;

        while (failures < MaxFailedAttempts)
        {
            var position = new Vector2(
                Random.Range(InitialPileAreaRect.xMin, InitialPileAreaRect.xMax),
                Random.Range(InitialPileAreaRect.yMin, InitialPileAreaRect.yMax));
            float rotation = Random.Range(RotationRange.x, RotationRange.y);
            Vector2[] candidate = TransformPolygon(shape, position, rotation);

            bool isValidPolygon = IsPolygonInsideArea(candidate, InitialPileAreaRect) && !IsCandidateOverlappingExistingPolygon(candidate, placedLeaves);
            if (isValidPolygon)
            {
                Spawn(position, rotation);
                placedLeaves.Add(candidate);
                failures = 0;
            }
            else
            {
                failures++;
            }
        }
    }
}
