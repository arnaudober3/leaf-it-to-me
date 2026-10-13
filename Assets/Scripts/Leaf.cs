using UnityEngine;

[RequireComponent(typeof(Rigidbody2D), typeof(PolygonCollider2D))]
public class Leaf : MonoBehaviour
{
    const int SortingOrderWhileDragged = 1;
    const float LinearVelocityXMin = -1.5f;
    const float LinearVelocityXMax = 1.5f;
    const float LinearVelocityYMin = -1.5f;
    const float LinearVelocityYMax = -0.5f;
    const float AngularVelocityMin = -2f * Mathf.Rad2Deg;
    const float AngularVelocityMax = 2f * Mathf.Rad2Deg;

    private Rigidbody2D rigidBody;
    private SpriteRenderer spriteRenderer;
    private int sortingOrder;

    void Awake()
    {
        // We create references to the Rigidbody2D and SpriteRenderer components and store the initial sorting order of the leaf
        rigidBody = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        sortingOrder = spriteRenderer.sortingOrder;
    }

    public void Animate()
    {
        // Animate the leaf while falling down with random linear and angular velocities so they move naturally
        rigidBody.linearVelocity = new Vector2(
            Random.Range(LinearVelocityXMin, LinearVelocityXMax),
            Random.Range(LinearVelocityYMin, LinearVelocityYMax));
        rigidBody.angularVelocity = Random.Range(AngularVelocityMin, AngularVelocityMax);
    }

    public void BeginDrag()
    {
        // Removes the leaf from the physics simulation while it is being dragged
        rigidBody.simulated = false;
        // Brings the leaf visually above the other leaves while it is being dragged
        spriteRenderer.sortingOrder = SortingOrderWhileDragged;
    }

    public void DragTo(Vector2 target)
    {
        // We use half because we are clamping based on the leaf's center, not its edges
        float halfLeafHeight = spriteRenderer.bounds.extents.y;
        // Using half screen height because the orthographic size represents half of the screen height in world units
        float halfScreenHeight = Camera.main.orthographicSize;

        target.y = Mathf.Clamp(target.y, -halfScreenHeight + halfLeafHeight, halfScreenHeight - halfLeafHeight);
        transform.position = target;
    }

    public void Release()
    {
        if (IsOutOfBounds())
            // Leaf is destroyed as not on the screen anymore
            Destroy(gameObject);
        else
            Drop(); // Case if the leaf is released somewhere on the screen
    }

    private void Drop()
    {
        // We put the leaf back into the physics simulation
        rigidBody.simulated = true;
        // The leaf visually returns to its original sorting order based on the creation order
        spriteRenderer.sortingOrder = sortingOrder;
        // We remove any residual motion from the leaf as it's not in motion anymore
        rigidBody.linearVelocity = Vector2.zero;
        rigidBody.angularVelocity = 0f;
    }

    private bool IsOutOfBounds()
    {
        // Check if the leaf is outside the visible area of the screen in viewport coordinates (0 to 1)
        Vector3 viewportPos = Camera.main.WorldToViewportPoint(transform.position);
        return viewportPos.x < 0f || viewportPos.x > 1f || viewportPos.y < 0f || viewportPos.y > 1f;
    }
}
